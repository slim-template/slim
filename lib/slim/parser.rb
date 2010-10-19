require 'strscan'

module Slim
  class Parser
    attr_reader :options

    class SyntaxError < StandardError
      def initialize(message, line, lineno, column = 0)
        @message = message
        @line = line.strip
        @lineno = lineno
        @column = column
      end

      def to_s
        <<-EOF
#{@message}
  Line #{@lineno}
    #{@line}
    #{' ' * @column}^
        EOF
      end
    end

    # A little helper for raising exceptions.
    def e(*args)
      raise SyntaxError.new(*args)
    end
    
    def initialize(options = {})
      @options = options
      @tabsize = options[:tabsize] || 4
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

      # We have special treatment for text blocks:
      # 
      #   |
      #     Hello
      #     World!
      in_text = false
      text_indent = nil
      
      str.each_line do |line|
        lineno += 1
        
        # Figure out the indentation. Kinda ugly/slow way to support tabs,
        # but remember that this is only done at parsing time.
        indent = line[/^[ \t]*/].gsub("\t", " " * @tabsize).size
        # Remove the indentation
        line.lstrip!
        # Remove the newline at the ned
        line.chop!

        if line.strip.empty?
          # This happens to be an empty line, so we'll just have to make sure
          # the generated code includes a newline (so the line numbers in the
          # stack trace for an exception matches the ones in the template).
          stacks.last << [:newline]
          next
        end

        if in_text
          # Now we're inside a text block:
          # 
          #   |
          #     Hello    <- this line
          #     World    <- or this line
          
          # The indentation of first line of the text block (also called the
          # base line below) determines the base indentation.
          text_indent ||= indent
          
          if indent >= text_indent
            # This line happens to be indented deeper (or equal) to the base
            # line. This means that it's a part of the text block.
             
            # Generate the additional spaces in front.
            i = " " * (indent - text_indent)
            stacks.last << [:slim, :text, i + line]
            stacks.last << [:newline]

            # Mark this line as it's been indented as the base line.
            indent = text_indent
          end
        end
        
        # If there's more stacks than indents, it means that the previous
        # line is expecting this line to be indented. 
        expecting_indentation = stacks.size > indents.size
        prev_indent = indents.last

        if indent > prev_indent
          # This line was actually indented, so we'll have to check if it was
          # supposed to be indented or not.
          if not expecting_indentation
            e "Unexpected indentation", line, lineno
          end

          indents << indent
        else
          # This line was *not* indented, so we'll just forget about the stack
          # that the previous line pushed.
          stacks.pop if expecting_indentation
        end

        if indent < prev_indent
          # This line was deindented.

          # It's guaranteed that we're now *not* in a text block, because
          # the indent will always be set to the base indent.
          in_text = false
          text_indent = nil

          # Now we're have to go through the all the indents and figure out
          # how many levels we've deindented.
          while true
            i = indents.last
            if i > indent
              # This line is indented deeper than the previous indented line
              # so let's just pop off the stacks.
              indents.pop
              stacks.pop
            elsif i == indent
              # Yay! We're back at the correct level!
              break
            elsif i < indent
              # This line's indentaion happens lie "between" two other line's
              # indentation:
              # 
              #   hello
              #       world
              #     this      # <- This should not be possible!
              e "Malformed indentation", line, lineno
            end
          end
        end

        # If we're still in a text block we don't need to do anything more;
        # we've already generated the needed code and made sure the stacks
        # are setup correctly.
        next if in_text

        # As mentioned above, this is were we will output exp
        current = stacks.last
        
        case line[0]
        when ?|, ?', ?`
          # Found a piece of text.
          
          # Remove an optional space.
          text = line[1..-1].sub(/^ /, '')

          if text.strip.empty?
            # We're now expecting the next line to be indented, so we'll need
            # to push a block to the stack. Text blocks are a special case, so
            # this code may not made very much sense. It's clearer in the other
            # examples below.
            block = [:multi]
            stacks << block
            current << block
            in_text = true
          else
            current << [:slim, :text, text]
          end
        when ?-
          # Found a piece of control code.
          
          # First of all we need to push a exp into the stack. Anything
          # indented deeper will be pushed into this exp. We'll include the
          # same exp in the current-stack, which makes sure that it'll be
          # included in the generated code.
          block = [:multi]
          stacks << block
          current << [:slim, :control, line[1..-1].strip, block]
        when ?=
          # Found a piece of (potentionally escaped) code.
          if line[1] == ?=
            current << [:slim, :output, line[2..-1].strip]
          else
            current << [:slim, :escaped_output, line[1..-1].strip]
          end
        when ?!
          # Found a directive (currently only used for doctypes)
          current << [:slim, :directive, line[1..-1].strip]
        when ?/
          # Found a comment. Do nothing
        else
          # Found a HTML tag.
          insert_newline = false
          exp, content = parse_tag(line, lineno)
          stacks << content if content
          current << exp
        end

        # Add a newline (to the generated code). We use stacks.last instead of
        # current because something might have been pushed to stacks.
        stacks.last << [:newline]
      end
      
      result
    end

    ATTR_SHORTHAND = {
      "#" => "id",
      "." => "class",
    }
    DELIMITERS = {
      "(" => ?),
      "[" => ?],
      "{" => ?},
    }
    
    def parse_tag(line, lineno)
      orig_line = line
      
      if line =~ /^(#|\.)/
        tag = "div"
      elsif line =~ /^[\w:]+/
        tag = $&
        line = $'
      else
        e "Unknown line indicator", orig_line, lineno
      end

      # Now we'll have to find all the attributes. We'll store these in an
      # nested array: [[name, value], [name2, value2]]. The value is a piece
      # of Ruby code.
      attributes = []
      
      # Find any literal class/id attributes
      while line =~ /^(#|\.)([\w\u00c0-\uFFFF-]+)/
        key = ATTR_SHORTHAND[$1]
        value = '"%s"' % $2
        attributes << [key, value]
        line = $'
      end
      
      # Check to see if there is a delimiter right after the tag name
      if line[0, 1] =~ /([()\[\]{}])/
        delimiter = $1
        # Replace the delimiter with a space so we can continue parsing as normal.
        line[0] = ?\s
      end

      # Find any other attributes
      while line =~ /^ ([\w-]+)=("[^"]+")/
        key = $1
        value = $2
        attributes << [key, value]
        line = $'
      end

      if delimiter && line[0] == DELIMITERS[delimiter]
        # Everything is ok!
        line = line[1..-1]
      elsif delimiter
        # Oops, we can't find a closing delimiter; report an error!
        e "Expected closing of attributes", orig_line, lineno, orig_line.size - line.size
      end

      # The rest of the line.
      rest = line.sub(/^ /, '')
      content = [:multi]

      if rest.strip.empty?
        # If the line was empty there might be some indented content in the
        # lines beneath it. We'll handle this by making this method return
        # the block-variable. #compile will then push this onto the
        # stacks-array.
        block = content
      else
        case rest
        when /^\s*==/
          content << [:slim, :output, $'.strip]
        when /^\s*=/
          content << [:slim, :escaped_output, $'.strip]
        else
          content << [:slim, :text, rest]
        end
      end

      return [:slim, :tag, tag, attributes, content], block
    end
  end
end

