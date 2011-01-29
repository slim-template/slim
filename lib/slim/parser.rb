module Slim
  # Parses Slim code and transforms it to a Temple expression
  # @api private
  class Parser
    include Temple::Mixins::Options

    class SyntaxError < StandardError
      attr_reader :error, :file, :line, :lineno, :column

      def initialize(error, file, line, lineno, column = 0)
        @error = error
        @file = file || '(__TEMPLATE__)'
        @line = line.strip
        @lineno = lineno
        @column = column
      end

      def to_s
        %{#{error}
  #{file}, Line #{lineno}
    #{line}
    #{' ' * column}^
        }
      end
    end

    default_options[:tabsize] = 4

    def initialize(options = {})
      super
      @tab = ' ' * @options[:tabsize]
    end

    # Compile string to Temple expression
    #
    # @param [String] str Slim code
    # @return [Array] Temple expression representing the code
    def compile(str)
      lineno = 0
      result = [:multi]

      # Since you can indent however you like in Slim, we need to keep a list
      # of how deeply indented you are. For instance, in a template like this:
      #
      #   ! doctype     # 0 spaces
      #   html          # 0 spaces
      #    head         # 1 space
      #       title     # 4 spaces
      #
      # indents will then contain [0, 1, 4] (when it's processing the last line.)
      #
      # We uses this information to figure out how many steps we must "jump"
      # out when we see an de-indented line.
      indents = [0]

      # Whenever we want to output something, we'll *always* output it to the
      # last stack in this array. So when there's a line that expects
      # indentation, we simply push a new stack onto this array. When it
      # processes the next line, the content will then be outputted into that
      # stack.
      stacks = [result]

      # String buffer used for broken line (Lines ending with \)
      broken_line = nil

      # We have special treatment for text blocks:
      #
      #   |
      #     Hello
      #     World!
      #
      block_indent, text_indent, in_comment = nil, nil, false

      str.each_line do |line|
        lineno += 1

        # Remove the newline at the end
        line.chomp!

        # Handle broken lines
        if broken_line
          if broken_line[-1] == ?\\
            broken_line << "\n" << line
            next
          end
          broken_line = nil
        end

        if line.strip.empty?
          # This happens to be an empty line, so we'll just have to make sure
          # the generated code includes a newline (so the line numbers in the
          # stack trace for an exception matches the ones in the template).
          stacks.last << [:newline]
          next
        end

        # Figure out the indentation. Kinda ugly/slow way to support tabs,
        # but remember that this is only done at parsing time.
        indent = line[/^[ \t]*/].gsub("\t", @tab).size

        # Remove the indentation
        line.lstrip!

        # Handle blocks with multiple lines
        if block_indent
          if indent > block_indent
            # This line happens to be indented deeper (or equal) than the block start character (|, ', /).
            # This means that it's a part of the block.

            if !in_comment
              # The indentation of first line of the text block determines the text base indentation.
              newline = text_indent ? "\n" : ''
              text_indent ||= indent

              # The text block lines must be at least indented as deep as the first line.
              offset = indent - text_indent
              syntax_error! 'Unexpected text indentation', line, lineno if offset < 0

              # Generate the additional spaces in front.
              stacks.last << [:slim, :text, newline + (' ' * offset) + line]
            end

            stacks.last << [:newline]
            next
          end

          # It's guaranteed that we're now *not* in a block, because
          # the indent was less than the block start indent.
          block_indent = text_indent = nil
          in_comment = false
        end

        # If there's more stacks than indents, it means that the previous
        # line is expecting this line to be indented.
        expecting_indentation = stacks.size > indents.size

        if indent > indents.last
          # This line was actually indented, so we'll have to check if it was
          # supposed to be indented or not.
          syntax_error! 'Unexpected indentation', line, lineno unless expecting_indentation

          indents << indent
        else
          # This line was *not* indented more than the line before,
          # so we'll just forget about the stack that the previous line pushed.
          stacks.pop if expecting_indentation

          # This line was deindented.
          # Now we're have to go through the all the indents and figure out
          # how many levels we've deindented.
          while indent < indents.last
            indents.pop
            stacks.pop
          end

          # This line's indentation happens lie "between" two other line's
          # indentation:
          #
          #   hello
          #       world
          #     this      # <- This should not be possible!
          syntax_error! 'Malformed indentation', line, lineno if indents.last < indent
        end

        case line[0]
        when ?|, ?', ?/
          # Found a block.
          ch = line.slice!(0)

          # We're now expecting the next line to be indented, so we'll need
          # to push a block to the stack.
          block = [:multi]
          stacks.last << if ch == ?'
                           # Additional whitespace in front
                           [:multi, block, [:slim, :text, ' ']]
                         elsif ch == ?/ && line[0] == ?!
                           # HTML comment
                           line.slice!(0)
                           [:slim, :comment, block]
                         else
                           in_comment = ch == ?/
                           block
                         end
          stacks << block
          block_indent = indent

          if !in_comment && !line.strip.empty?
            block << [:slim, :text, line.sub(/^( )/, '')]
            text_indent = block_indent + ($1 ? 2 : 1)
          end
        when ?-
          # Found a code block.
          # We expect the line to be broken or the next line to be indented.
          block = [:multi]
          broken_line = line[1..-1].strip
          stacks.last << [:slim, :control, broken_line, block]
          stacks << block
        when ?=
          # Found an output block.
          # We expect the line to be broken or the next line to be indented.
          block = [:multi]
          escape = line[1] != ?=
          broken_line = escape ? line[1..-1].strip : line[2..-1].strip
          stacks.last << [:slim, :output, escape, broken_line, block]
          stacks << block
        when ?!
          # Found a directive (currently only used for doctypes)
          stacks.last << [:slim, :directive, line[1..-1].strip]
        else
          if line =~ /^(\w+):\s*$/
            # Embedded template detected. It is treated as block.
            block = [:slim, :embedded, $1]
            stacks.last << [:newline] << block
            stacks << block
            block_indent = indent
            next
          else
            # Found a HTML tag.
            tag, block, broken_line, text_indent = parse_tag(line, lineno)
            stacks.last << tag
            stacks << block if block
            if text_indent
              block_indent = indent
              text_indent += indent
            end
          end
        end
        stacks.last << [:newline]
      end

      result
    end

    DELIMITERS = {
      '(' => ')',
      '[' => ']',
      '{' => '}',
    }.freeze
    DELIMITER_REGEX = /^[\(\[\{]/
    CLOSE_DELIMITER_REGEX = /^[\)\]\}]/

    private

    ATTR_REGEX = /^\s+(\w[:\w-]*)=/
    QUOTED_VALUE_REGEX = /^("[^"]+"|'[^']+')/
    ATTR_SHORTHAND = {
      '#' => 'id',
      '.' => 'class',
    }.freeze

    if RUBY_VERSION > '1.9'
      CLASS_ID_REGEX = /^(#|\.)([\w\u00c0-\uFFFF][\w:\u00c0-\uFFFF-]*)/
    else
      CLASS_ID_REGEX = /^(#|\.)(\w[\w:-]*)/
    end

    def parse_tag(line, lineno)
      orig_line = line

      case line
      when /^[#\.]/
        tag = 'div'
      when /^\w[:\w-]*/
        tag = $&
        line = $'
      else
        syntax_error! 'Unknown line indicator', orig_line, lineno
      end

      # Now we'll have to find all the attributes. We'll store these in an
      # nested array: [[name, value], [name2, value2]]. The value is a piece
      # of Ruby code.
      attributes = [:slim, :attrs]

      # Find any literal class/id attributes
      while line =~ CLASS_ID_REGEX
        attributes << [ATTR_SHORTHAND[$1], [:static, $2]]
        line = $'
      end

      # Check to see if there is a delimiter right after the tag name
      delimiter = ''
      if line =~ DELIMITER_REGEX
        delimiter = DELIMITERS[$&]
        # Replace the delimiter with a space so we can continue parsing as normal.
        line[0] = ?\s
      end

      # Parse attributes
      while line =~ ATTR_REGEX
        key = $1
        line = $'
        if line =~ QUOTED_VALUE_REGEX
          # Value is quoted (static)
          line = $'
          attributes << [key, [:slim, :text, $1[1..-2]]]
        else
          # Value is ruby code
          line, value = parse_ruby_attribute(orig_line, line, lineno, delimiter)
          attributes << [key, [:slim, :output, true, value, [:multi]]]
        end
      end

      # Find ending delimiter
      if !delimiter.empty?
        if line =~ /^\s*#{Regexp.escape delimiter}/
          line = $'
        else
          syntax_error! "Expected closing delimiter #{delimiter}", orig_line, lineno, orig_line.size - line.size
        end
      end

      content = [:multi]
      tag = [:slim, :tag, tag, attributes, false, content]

      if line =~ /^\s*=(=?)/
        # Handle output code
        block = [:multi]
        broken_line = $'.strip
        content << [:slim, :output, $1 != '=', broken_line, block]
        [tag, block, broken_line, nil]
      elsif line =~ /^\s*\//
        # Closed tag
        tag[4] = true
        [tag, block, nil, nil]
      elsif line =~ /^\s*$/
        # Empty line
        [tag, content, nil, nil]
      else
        # Handle text content
        content << [:slim, :text, line.sub(/^( )/, '')]
        [tag, content, nil, orig_line.size - line.size + ($1 ? 1 : 0)]
      end
    end

    def parse_ruby_attribute(orig_line, line, lineno, delimiter)
      # Delimiter stack
      stack = []

      # Attribute value buffer
      value = ''

      # Attribute ends with space or attribute delimiter
      end_regex = /^[\s#{Regexp.escape delimiter}]/

      until line.empty?
        if stack.empty? && line =~ end_regex
          # Stack is empty, this means we left the attribute value
          # if next character is space or attribute delimiter
          break
        elsif line =~ DELIMITER_REGEX
          # Delimiter found, push it on the stack
          stack << DELIMITERS[$&]
          value << line.slice!(0)
        elsif line =~ CLOSE_DELIMITER_REGEX
          # Closing delimiter found, pop it from the stack if everything is ok
          syntax_error! "Unexpected closing #{$&}", orig_line, lineno if stack.empty?
          syntax_error! "Expected closing #{stack.last}", orig_line, lineno if stack.last != $&
          value << line.slice!(0)
          stack.pop
        else
          value << line.slice!(0)
        end
      end

      syntax_error! "Expected closing attribute delimiter #{stack.last}", orig_line, lineno if !stack.empty?
      syntax_error! 'Invalid empty attribute', orig_line, lineno if value.empty?

      # Remove attribute wrapper which doesn't belong to the ruby code
      # e.g id=[hash[:a] + hash[:b]]
      value = value[1..-2] if value =~ DELIMITER_REGEX && DELIMITERS[$&] == value[-1, 1]

      return line, value
    end

    # A little helper for raising exceptions.
    def syntax_error!(message, *args)
      raise SyntaxError.new(message, options[:file], *args)
    end
  end
end
