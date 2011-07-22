module Slim
  # Parses Slim code and transforms it to a Temple expression
  # @api private
  class Parser
    include Temple::Mixins::Options

    set_default_options :tabsize  => 4,
                        :encoding => 'utf-8'

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

    def initialize(options = {})
      super
      @tab = ' ' * @options[:tabsize]
    end

    # Compile string to Temple expression
    #
    # @param [String] str Slim code
    # @return [Array] Temple expression representing the code
    def call(str)
      # Set string encoding if option is set
      if options[:encoding] && str.respond_to?(:encoding)
        old = str.encoding
        str = str.dup if str.frozen?
        str.force_encoding(options[:encoding])
        # Fall back to old encoding if new encoding is invalid
        str.force_encoding(old_enc) unless str.valid_encoding?
      end

      lineno = 0
      result = [:multi]

      # Since you can indent however you like in Slim, we need to keep a list
      # of how deeply indented you are. For instance, in a template like this:
      #
      #   doctype       # 0 spaces
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
      in_comment, block_indent, text_indent,
        current_tag, delimiter, delimiter_line,
        delimiter_lineno  = false, nil, nil, nil, nil, nil, nil

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

        # Figure out the indentation. Kinda ugly/slow way to support tabs,
        # but remember that this is only done at parsing time.
        indent = line[/\A[ \t]*/].gsub("\t", @tab).size

        # Remove the indentation
        line.lstrip!

        # Handle blocks with multiple lines
        if block_indent
          if indent > block_indent
            # This line happens to be indented deeper (or equal) than the block start character (|, ', /).
            # This means that it's a part of the block.

            unless in_comment
              # The indentation of first line of the text block determines the text base indentation.
              newline = text_indent ? "\n" : ''
              text_indent ||= indent

              # The text block lines must be at least indented as deep as the first line.
              offset = indent - text_indent
              if offset < 0
                syntax_error!('Unexpected text indentation', line, lineno)
              end

              # Generate the additional spaces in front.
              stacks.last << [:slim, :interpolate, newline + (' ' * offset) + line]
            end

            stacks.last << [:newline]
            next
          end

          # It's guaranteed that we're now *not* in a block, because
          # the indent was less than the block start indent.
          block_indent = text_indent = nil
          in_comment = false
        end

        if line.strip.empty?
          # This happens to be an empty line, so we'll just have to make sure
          # the generated code includes a newline (so the line numbers in the
          # stack trace for an exception matches the ones in the template).
          stacks.last << [:newline]
          next
        end

        # If there's more stacks than indents, it means that the previous
        # line is expecting this line to be indented.
        expecting_indentation = stacks.size > indents.size

        if indent > indents.last
          # This line was actually indented, so we'll have to check if it was
          # supposed to be indented or not.
          unless expecting_indentation
            syntax_error!('Unexpected indentation', line, lineno)
          end

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
          if indents.last < indent
            syntax_error!('Malformed indentation', line, lineno)
          end
        end

        case line
        when /\A\//
          # Found a comment block.
          block = [:multi]
          stacks.last <<  if line =~ %r{\A/!( ?)(.*)\Z}
                            # HTML comment
                            block_indent = indent
                            text_indent = block_indent + ($1 ? 2 : 1)
                            block << [:slim, :interpolate, $2] if $2
                            [:html, :comment, block]
                          elsif line =~ %r{\A/\[\s*(.*?)\s*\]\s*\Z}
                            # HTML conditional comment
                            [:slim, :condcomment, $1, block]
                          else
                            # Slim comment
                            block_indent = indent
                            in_comment = true
                            block
                          end
          stacks << block
        when /\A\|/, /\A'/
          # Found a text block.
          # We're now expecting the next line to be indented, so we'll need
          # to push a block to the stack.
          block = [:multi]
          block_indent = indent
          stacks.last << (line.slice!(0) == ?' ?
                          [:multi, block, [:static, ' ']] : block)
          stacks << block
          unless line.strip.empty?
            block << [:slim, :interpolate, line.sub(/\A( )/, '')]
            text_indent = block_indent + ($1 ? 2 : 1)
          end
        when /\A-/
          # Found a code block.
          # We expect the line to be broken or the next line to be indented.
          block = [:multi]
          broken_line = line[1..-1].strip
          stacks.last << [:slim, :control, broken_line, block]
          stacks << block
        when /\A=/
          # Found an output block.
          # We expect the line to be broken or the next line to be indented.
          line =~ /\A=(=?)('?)/
          broken_line = $'.strip
          block = [:multi]
          stacks.last << [:slim, :output, $1.empty?, broken_line, block]
          stacks.last << [:static, ' '] unless $2.empty?
          stacks << block
        when /\A(\w+):\s*\Z/
          # Embedded template detected. It is treated as block.
          block = [:multi]
          stacks.last << [:newline] << [:slim, :embedded, $1, block]
          stacks << block
          block_indent = indent
          next
        when /\Adoctype\s+/i
          # Found doctype declaration
          stacks.last << [:html, :doctype, $'.strip]
        when /\A[#\.]/, /\A\w[:\w-]*/
          # Found an HTML tag or attribute
          tag, block, broken_line, text_indent, end_delimiter = parse_tag($&, $', line, lineno, delimiter)

          if delimiter
            # We are in attribute parsing mode and parse_tag returned attributes
            # to be added to the tag.
            current_tag[-2] << tag
            current_tag[-1] << block if block
          else
            # Standard tag parsing mode
            current_tag = tag
            stacks.last << current_tag
            stacks << block if block
          end

          if text_indent
            block_indent = indent
            text_indent += indent
          end

          # If end_delimiter was returned we are in attribute parsing
          # mode. Set it as the delimiter to denote this state.
          if delimiter = end_delimiter
            # Save this information for easy error reporting
            # if closing delimiter is not found
            delimiter_line = line
            delimiter_lineno = lineno
          end
        else
          syntax_error! 'Unknown line indicator', line, lineno
        end
        stacks.last << [:newline] unless delimiter
      end

      if delimiter
        syntax_error! "Expected closing delimiter #{delimiter}", delimiter_line, delimiter_lineno
      end

      result
    end

    DELIMITERS = {
      '(' => ')',
      '[' => ']',
      '{' => '}',
    }.freeze
    DELIMITER_REGEX = /\A[\(\[\{]/
    CLOSE_DELIMITER_REGEX = /\A[\)\]\}]/

    private

    ATTR_REGEX = /\A\s*(\w[:\w-]*)=/
    QUOTED_VALUE_REGEX = /\A("[^"]*"|'[^']*')/
    ATTR_SHORTHAND = {
      '#' => 'id',
      '.' => 'class',
    }.freeze

    if RUBY_VERSION > '1.9'
      CLASS_ID_REGEX = /\A(#|\.)([\w\u00c0-\uFFFF][\w:\u00c0-\uFFFF-]*)/
    else
      CLASS_ID_REGEX = /\A(#|\.)(\w[\w:-]*)/
    end

    def parse_tag(tag, line, orig_line, lineno, delimiter)
      in_attribute_mode = !delimiter.nil?

      if tag == ?# || tag == ?.
        tag = 'div'
        line = orig_line
      elsif in_attribute_mode
        line = orig_line
      end

      if in_attribute_mode
        attributes = []
      else
        attributes = [:html, :attrs]
      end

      unless line.empty?
        # Find any literal class/id attributes
        while line =~ CLASS_ID_REGEX
          # The class/id attribute is :static instead of :slim :text,
          # because we don't want text interpolation in .class or #id shortcut
          attributes << [:html, :attr, ATTR_SHORTHAND[$1], [:static, $2]]
          line = $'
        end

        # Check to see if there is a delimiter right after the tag name
        if line =~ DELIMITER_REGEX
          delimiter = DELIMITERS[$&]
          # Replace the delimiter with a space so we can continue parsing as normal.
          line[0] = ?\s
        end

        line, attributes, delimiter = parse_attributes(attributes, orig_line, line, lineno, delimiter)
      end

      content = [:multi]
      tag = [:html, :tag, tag, attributes, content]

      case line
      when /\A\s*=(=?)/
        # Handle output code
        block = [:multi]
        broken_line = $'.strip
        content << [:slim, :output, $1 != '=', broken_line, block]
        if in_attribute_mode
          [attributes[0], content , broken_line, nil, delimiter]
        else
          [tag, block, broken_line, nil, delimiter]
        end
      when /\A\s*\//
        # Closed tag
        tag.pop
        [tag, nil, nil, nil, delimiter]
      when /\A\s*\Z/
        # Empty line
        if in_attribute_mode
          [attributes[0], nil, nil, 1, delimiter]
        else
          [tag, content, nil, nil, delimiter]
        end
      else
        # Handle text content
        content << [:slim, :interpolate, line.sub(/\A( )/, '')]
        indent = orig_line.size - line.size + ($1 ? 1 : 0)
        if in_attribute_mode
          [attributes[0], content, nil, indent, delimiter]
        else
          [tag, content, nil, indent, delimiter]
        end
      end
    end

    def parse_attributes(attributes, orig_line, line, lineno, delimiter)
      # Now we'll have to find all the attributes. We'll store these in an
      # nested array: [[name, value], [name2, value2]]. The value is a piece
      # of Ruby code.

      # Parse attributes
      while line =~ ATTR_REGEX
        name = $1
        line = $'
        if line =~ QUOTED_VALUE_REGEX
          # Value is quoted (static)
          line = $'
          attributes << [:html, :attr, name, [:slim, :interpolate, $1[1..-2]]]
        else
          # Value is ruby code
          escape = line[0] != ?=
          line, code = parse_ruby_attribute(orig_line, escape ? line : line[1..-1], lineno, delimiter)
          attributes << [:slim, :attr, name, escape, code]
        end
      end

      # Find ending delimiter
      if delimiter && line =~ /\A\s*#{Regexp.escape delimiter}/
        line = $'
        delimiter = nil
      end

      return line, attributes, delimiter
    end

    def parse_ruby_attribute(orig_line, line, lineno, delimiter)
      # Delimiter stack
      stack = []

      # Attribute value buffer
      value = ''

      # Attribute ends with space or attribute delimiter
      end_regex = /\A[\s#{Regexp.escape delimiter.to_s}]/

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
          if stack.empty?
            syntax_error!("Unexpected closing #{$&}", orig_line, lineno)
          end
          if stack.last != $&
            syntax_error!("Expected closing #{stack.last}", orig_line, lineno)
          end
          value << line.slice!(0)
          stack.pop
        else
          value << line.slice!(0)
        end
      end

      unless stack.empty?
        syntax_error!("Expected closing attribute delimiter #{stack.last}", orig_line, lineno)
      end

      if value.empty?
        syntax_error!('Invalid empty attribute', orig_line, lineno)
      end

      # Remove attribute wrapper which doesn't belong to the ruby code
      # e.g id=[hash[:a] + hash[:b]]
      value = value[1..-2] if value =~ DELIMITER_REGEX && DELIMITERS[$&] == value[-1, 1]

      return line, value
    end

    # Helper for raising exceptions
    def syntax_error!(message, *args)
      raise SyntaxError.new(message, options[:file], *args)
    end
  end
end
