module Slim
  class Parser
    class SyntaxError < StandardError
      def initialize(message, line, lineno, column = 0)
        @message = message
        @line = line.strip
        @lineno = lineno
        @column = column
      end

      def to_s
        %{#{@message}
  Line #{@lineno}
    #{@line}
    #{' ' * @column}^
        }
      end
    end

    attr_reader :options

    def initialize(options = {})
      @options = options
      @tab     = ' ' * (options[:tabsize] || 4)
    end

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
      text_indent, text_base_indent = nil, nil

      str.each_line do |line|
        lineno += 1

        # Remove the newline at the ned
        line.chop!

        # Handle broken lines
        if broken_line
          if broken_line[-1] == ?\\
            broken_line << "\n#{line}"
            next
          end
          broken_line = nil
        end

        # Figure out the indentation. Kinda ugly/slow way to support tabs,
        # but remember that this is only done at parsing time.
        indent = line[/^[ \t]*/].gsub("\t", @tab).size

        # Remove the indentation
        line.lstrip!

        if line.strip.empty? || line[0] == ?/
          # This happens to be an empty line or a comment, so we'll just have to make sure
          # the generated code includes a newline (so the line numbers in the
          # stack trace for an exception matches the ones in the template).
          stacks.last << [:newline]
          next
        end

        # Handle text blocks with multiple lines
        if text_indent
          if indent > text_indent
            # This line happens to be indented deeper (or equal) than the block start character (|, ', `).
            # This means that it's a part of the text block.

            # The indentation of first line of the text block determines the text base indentation.
            text_base_indent ||= indent

            # The text block lines must be at least indented as deep as the first line.
            offset = indent - text_base_indent
            syntax_error! 'Unexpected text indentation', line, lineno if offset < 0

            # Generate the additional spaces in front.
            i = ' ' * offset
            stacks.last << [:slim, :text, i + line]
            stacks.last << [:newline]

            # Mark this line as it's been indented as the text block start character.
            indent = text_indent

            next
          end

          # It's guaranteed that we're now *not* in a text block, because
          # the indent will always be set to the text block start indent.
          text_indent = text_base_indent = nil
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
        when ?|, ?', ?`
          # Found a piece of text.

          # We're now expecting the next line to be indented, so we'll need
          # to push a block to the stack.
          block = [:multi]
          stacks.last << block
          stacks << block
          text_indent = indent

          line.slice!(0)
          if !line.strip.empty?
            block << [:slim, :text, line.sub(/^( )/, '')]
            text_base_indent = text_indent + ($1 ? 2 : 1)
          end
        when ?-, ?=
          # Found a potential code block.

          # First of all we need to push a exp into the stack. Anything
          # indented deeper will be pushed into this exp. We'll include the
          # same exp in the current-stack, which makes sure that it'll be
          # included in the generated code.
          block = [:multi]
          if line[1] == ?=
            broken_line = line[2..-1].strip
            stacks.last << [:slim, :output, false, broken_line, block]
          elsif line[0] == ?=
            broken_line = line[1..-1].strip
            stacks.last << [:slim, :output, true, broken_line, block]
          else
            broken_line = line[1..-1].strip
            stacks.last << [:slim, :control, broken_line, block]
          end
          stacks << block
        when ?!
          # Found a directive (currently only used for doctypes)
          stacks.last << [:slim, :directive, line[1..-1].strip]
        else
          if line =~ /^(\w+):\s*$/
            # Embedded template detected. It is treated like a text block.
            block = [:slim, :embedded, $1]
            stacks.last << block
            stacks << block
            text_indent = indent
          else
            # Found a HTML tag.
            exp, content, broken_line = parse_tag(line, lineno)
            stacks.last << exp
            stacks << content if content
          end
        end
      end

      result
    end

    private

    ATTR_REGEX = /^ ([\w-]+)=/
    QUOTED_VALUE_REGEX = /("[^"]+"|'[^']+')/
    ATTR_SHORTHAND = {
      '#' => 'id',
      '.' => 'class',
    }
    DELIMITERS = {
      '(' => ')',
      '[' => ']',
      '{' => '}',
    }
    DELIMITER_REGEX = /^([\(\[\{])/
    if RUBY_VERSION > '1.9'
      CLASS_ID_REGEX = /^(#|\.)([\w\u00c0-\uFFFF][\w:\u00c0-\uFFFF-]*)/
    else
      CLASS_ID_REGEX = /^(#|\.)([\w][\w:-]*)/
    end

    def parse_tag(line, lineno)
      orig_line = line

      if line =~ /^(#|\.)/
        tag = 'div'
      elsif line =~ /^[\w:]+/
        tag = $&
        line = $'
      else
        syntax_error! 'Unknown line indicator', orig_line, lineno
      end

      # Now we'll have to find all the attributes. We'll store these in an
      # nested array: [[name, value], [name2, value2]]. The value is a piece
      # of Ruby code.
      attributes = []

      # Find any literal class/id attributes
      while line =~ CLASS_ID_REGEX
        attributes << [ATTR_SHORTHAND[$1], $2]
        line = $'
      end

      # Check to see if there is a delimiter right after the tag name
      delimiter = ''
      if line =~ DELIMITER_REGEX
        delimiter = DELIMITERS[$1]
        # Replace the delimiter with a space so we can continue parsing as normal.
        line[0] = ?\s
      end

      # Parse attributes
      while line =~ ATTR_REGEX
        key = $1
        line = $'
        case line
        when DELIMITER_REGEX
          # Value is a delimited ruby expression
          line = $'
          alpha, omega = $1, DELIMITERS[$1]
          # Count opening and closing brackets
          count, i = 1, -1
          while count > 0 && i < line.length
            i += 1
            case line[i, 1]
            when alpha
              count += 1
            when omega
              count -= 1
            end
          end
          syntax_error! "Expected closing attribute delimiter #{omega}", orig_line, lineno if count != 0
          value = '#{%s}' % line[0, i]
          line.slice!(0..i)
        when QUOTED_VALUE_REGEX
          # Value is quoted
          line = $'
          value = $1[1..-2]
        when /^([^\s#{delimiter}]+)/
          # Value is unquoted (ruby variable for example)
          line = $'
          value = '#{%s}' % $1
        else
          syntax_error! 'Invalid attribute value', orig_line, lineno
        end
        attributes << [key, value]
      end

      # Find ending delimiter
      if !delimiter.empty?
        if line[0, 1] == delimiter
          line.slice!(0)
        else
          syntax_error! "Expected closing attribute delimiter #{delimiter}", orig_line, lineno, orig_line.size - line.size
        end
      end

      content = [:multi]
      broken_line = nil

      if line.strip.empty?
        # If the line was empty there might be some indented content in the
        # lines beneath it. We'll handle this by making this method return
        # the block-variable. #compile will then push this onto the
        # stacks-array.
        block = content
      elsif line =~ /^\s*=(=?)/
        # Output
        block = [:multi]
        broken_line = $'.strip
        content << [:slim, :output, $1 != '=', broken_line, block]
      else
        # Text content
        line.sub!(/^ /, '')
        content << [:slim, :text, line]
      end

      return [:slim, :tag, tag, attributes, content], block, broken_line
    end

    # A little helper for raising exceptions.
    def syntax_error!(*args)
      raise SyntaxError.new(*args)
    end
  end
end
