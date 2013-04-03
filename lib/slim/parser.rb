module Slim
  # Parses Slim code and transforms it to a Temple expression
  # @api private
  class Parser < Temple::Parser
    define_options :file,
                   :default_tag,
                   :escape_quoted_attrs,
                   :tabsize => 4,
                   :encoding => 'utf-8',
                   :shortcut => {
                     '#' => { :attr => 'id' },
                     '.' => { :attr => 'class' }
                   }

    class SyntaxError < StandardError
      attr_reader :error, :file, :line, :lineno, :column

      def initialize(error, file, line, lineno, column)
        @error = error
        @file = file || '(__TEMPLATE__)'
        @line = line.to_s
        @lineno = lineno
        @column = column
      end

      def to_s
        line = @line.lstrip
        column = @column + line.size - @line.size
        %{#{error}
  #{file}, Line #{lineno}, Column #{@column}
    #{line}
    #{' ' * column}^
}
      end
    end

    def initialize(opts = {})
      super
      tabsize = options[:tabsize]
      if tabsize > 1
        @tab_re = /\G((?: {#{tabsize}})*) {0,#{tabsize-1}}\t/
        @tab = '\1' + ' ' * tabsize
      else
        @tab_re = "\t"
        @tab = ' '
      end
      @tag_shortcut, @attr_shortcut = {}, {}
      options[:shortcut].each do |k,v|
        v = deprecated_shortcut(v) if String === v
        raise ArgumentError, 'Shortcut requires :tag and/or :attr' unless (v[:attr] || v[:tag]) && (v.keys - [:attr, :tag]).empty?
        @tag_shortcut[k] = v[:tag] || options[:default_tag]
        if v.include?(:attr)
          @attr_shortcut[k] = v[:attr]
          raise ArgumentError, 'You can only use special characters for attribute shortcuts' if k =~ /[\w-]/
        end
      end
      @attr_shortcut_regex = /\A(#{Regexp.union @attr_shortcut.keys})(\w[\w-]*\w|\w+)/
      @tag_regex = /\A(?:#{Regexp.union @tag_shortcut.keys}|\*(?=[^\s]+)|(\w[\w:-]*\w|\w+))/
    end

    # Compile string to Temple expression
    #
    # @param [String] str Slim code
    # @return [Array] Temple expression representing the code]]
    def call(str)
      str = remove_bom(set_encoding(str))

      result = [:multi]
      reset(str.split(/\r?\n/), [result])

      parse_line while next_line

      reset
      result
    end

    protected

    DELIMITERS = {
      '(' => ')',
      '[' => ']',
      '{' => '}',
    }.freeze

    ATTR_DELIM_REGEX = /\A\s*[#{Regexp.escape DELIMITERS.keys.join}]/
    DELIMITER_REGEX = /\A[#{Regexp.escape DELIMITERS.keys.join}]/
    ATTR_NAME = '\A\s*(\w[:\w-]*)'
    QUOTED_ATTR_REGEX = /#{ATTR_NAME}=(=?)("|')/
    CODE_ATTR_REGEX = /#{ATTR_NAME}=(=?)/
    QUOTED_ATTR_REGEX_20 = /#{ATTR_NAME}\s*=(=?)\s*("|')/
    CODE_ATTR_REGEX_20 = /#{ATTR_NAME}\s*=(=?)\s*/

    # Convert deprecated string shortcut to hash
    def deprecated_shortcut(v)
      warn "Slim :shortcut string values are deprecated and unsupported in Slim 2.0, use hash like { '#' => { :tag => 'div', :attr => 'id' } }"
      if v =~ /\A([^\s]+)\s+([^\s]+)\Z/
        { :tag => $1, :attr => $2 }
      else
        { :attr => v }
      end
    end

    # Set string encoding if option is set
    def set_encoding(s)
      if options[:encoding] && s.respond_to?(:encoding)
        old_enc = s.encoding
        s = s.dup if s.frozen?
        s.force_encoding(options[:encoding])
        # Fall back to old encoding if new encoding is invalid
        unless s.valid_encoding?
          s.force_encoding(old_enc)
          s.force_encoding(Encoding::BINARY) unless s.valid_encoding?
        end
      end
      s
    end

    # Remove unicode byte order mark from string
    def remove_bom(s)
      if s.respond_to?(:encoding)
        if s.encoding.name =~ /^UTF-(8|16|32)(BE|LE)?/
          s.gsub(Regexp.new("\\A\uFEFF".encode(s.encoding.name)), '')
        else
          s
        end
      else
        s.gsub(/\A\xEF\xBB\xBF/, '')
      end
    end

    def reset(lines = nil, stacks = nil)
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
      @indents = [0]

      # Whenever we want to output something, we'll *always* output it to the
      # last stack in this array. So when there's a line that expects
      # indentation, we simply push a new stack onto this array. When it
      # processes the next line, the content will then be outputted into that
      # stack.
      @stacks = stacks

      @lineno = 0
      @lines = lines
      @line = @orig_line = nil
    end

    def next_line
      if @lines.empty?
        @orig_line = @line = nil
      else
        @orig_line = @lines.shift
        @lineno += 1
        @line = @orig_line.dup
      end
    end

    def get_indent(line)
      # Figure out the indentation. Kinda ugly/slow way to support tabs,
      # but remember that this is only done at parsing time.
      line[/\A[ \t]*/].gsub(@tab_re, @tab).size
    end

    def parse_line
      if @line =~ /\A\s*\Z/
        @stacks.last << [:newline]
        return
      end

      indent = get_indent(@line)

      # Remove the indentation
      @line.lstrip!

      # If there's more stacks than indents, it means that the previous
      # line is expecting this line to be indented.
      expecting_indentation = @stacks.size > @indents.size

      if indent > @indents.last
        # This line was actually indented, so we'll have to check if it was
        # supposed to be indented or not.
        syntax_error!('Unexpected indentation') unless expecting_indentation

        @indents << indent
      else
        # This line was *not* indented more than the line before,
        # so we'll just forget about the stack that the previous line pushed.
        @stacks.pop if expecting_indentation

        # This line was deindented.
        # Now we're have to go through the all the indents and figure out
        # how many levels we've deindented.
        while indent < @indents.last
          @indents.pop
          @stacks.pop
        end

        # This line's indentation happens lie "between" two other line's
        # indentation:
        #
        #   hello
        #       world
        #     this      # <- This should not be possible!
        syntax_error!('Malformed indentation') if indent != @indents.last
      end

      parse_line_indicators
    end

    def parse_line_indicators
      case @line
      when /\A\/!( ?)/
        # HTML comment
        @stacks.last << [:html, :comment, [:slim, :text, parse_text_block($', @indents.last + $1.size + 2)]]
      when /\A\/\[\s*(.*?)\s*\]\s*\Z/
        # HTML conditional comment
        block = [:multi]
        @stacks.last << [:html, :condcomment, $1, block]
        @stacks << block
      when /\A\//
        # Slim comment
        parse_comment_block
      when /\A([\|'])( ?)/
        # Found a text block.
        trailing_ws = $1 == "'"
        @stacks.last << [:slim, :text, parse_text_block($', @indents.last + $2.size + 1)]
        @stacks.last << [:static, ' '] if trailing_ws
      when /\A</
        # Inline html
        # @stacks.last << parse_text_block(@line, @indents.last + 1)
        block = [:multi]
        @stacks.last << [:multi, [:slim, :interpolate, @line], block]
        @stacks << block
      when /\A-/
        # Found a code block.
        # We expect the line to be broken or the next line to be indented.
        @line.slice!(0)
        block = [:multi]
        @stacks.last << [:slim, :control, parse_broken_line, block]
        @stacks << block
      when /\A=/
        # Found an output block.
        # We expect the line to be broken or the next line to be indented.
        @line =~ /\A=(=?)('?)/
        @line = $'
        block = [:multi]
        @stacks.last << [:slim, :output, $1.empty?, parse_broken_line, block]
        @stacks.last << [:static, ' '] unless $2.empty?
        @stacks << block
      when /\A(\w+):\s*\Z/
        # Embedded template detected. It is treated as block.
        @stacks.last << [:slim, :embedded, $1, parse_text_block]
      when /\Adoctype\s+/i
        # Found doctype declaration
        @stacks.last << [:html, :doctype, $'.strip]
      when @tag_regex
        # Found a HTML tag.
        @line = $' if $1
        parse_tag($&)
      else
        syntax_error! 'Unknown line indicator'
      end
      @stacks.last << [:newline]
    end

    def parse_comment_block
      while !@lines.empty? && (@lines.first =~ /\A\s*\Z/ || get_indent(@lines.first) > @indents.last)
        next_line
        @stacks.last << [:newline]
      end
    end

    def parse_text_block(first_line = nil, text_indent = nil, in_tag = false)
      result = [:multi]
      if !first_line || first_line.empty?
        text_indent = nil
      else
        result << [:slim, :interpolate, first_line]
      end

      empty_lines = 0
      until @lines.empty?
        if @lines.first =~ /\A\s*\Z/
          next_line
          result << [:newline]
          empty_lines += 1 if text_indent
        else
          indent = get_indent(@lines.first)
          break if indent <= @indents.last

          if empty_lines > 0
            result << [:slim, :interpolate, "\n" * empty_lines]
            empty_lines = 0
          end

          next_line
          @line.lstrip!

          # The text block lines must be at least indented
          # as deep as the first line.
          offset = text_indent ? indent - text_indent : 0
          if offset < 0
            syntax_error!("Text line not indented deep enough.\n" +
                          "The first text line defines the necessary text indentation." +
                          (in_tag ? "\nAre you trying to nest a child tag in a tag containing text? Use | for the text block!" : ''))
          end

          result << [:newline] << [:slim, :interpolate, (text_indent ? "\n" : '') + (' ' * offset) + @line]

          # The indentation of first line of the text block
          # determines the text base indentation.
          text_indent ||= indent
        end
      end
      result
    end

    def parse_broken_line
      broken_line = @line.strip
      while broken_line =~ /[,\\]\Z/
        expect_next_line
        broken_line << "\n" << @line
      end
      broken_line
    end

    def parse_tag(tag)
      if @tag_shortcut[tag]
        @line.slice!(0, tag.size) unless @attr_shortcut[tag]
        tag = @tag_shortcut[tag]
      end

      tag = [:html, :tag, tag, parse_attributes]
      @stacks.last << tag

      case @line
      when /\A\s*:\s*/
        # Block expansion
        @line = $'
        (@line =~ @tag_regex) || syntax_error!('Expected tag')
        @line = $' if $1
        content = [:multi]
        tag << content
        i = @stacks.size
        @stacks << content
        parse_tag($&)
        @stacks.delete_at(i)
      when /\A\s*=(=?)('?)/
        # Handle output code
        @line = $'
        block = [:multi]
        tag << [:slim, :output, $1 != '=', parse_broken_line, block]
        @stacks.last << [:static, ' '] unless $2.empty?
        @stacks << block
      when /\A\s*\/\s*/
        # Closed tag. Do nothing
        @line = $'
        syntax_error!('Unexpected text after closed tag') unless @line.empty?
      when /\A\s*\Z/
        # Empty content
        content = [:multi]
        tag << content
        @stacks << content
      when /\A( ?)(.*)\Z/
        # Text content
        tag << [:slim, :text, parse_text_block($2, @orig_line.size - @line.size + $1.size, true)]
      end
    end

    def parse_attributes
      attributes = [:html, :attrs]

      # Find any shortcut attributes
      while @line =~ @attr_shortcut_regex
        # The class/id attribute is :static instead of :slim :interpolate,
        # because we don't want text interpolation in .class or #id shortcut
        attributes << [:html, :attr, @attr_shortcut[$1], [:static, $2]]
        @line = $'
      end

      # Check to see if there is a delimiter right after the tag name
      delimiter = nil
      if @line =~ ATTR_DELIM_REGEX
        if $&.size > 1
          warn "#{options[:file]}:#{@lineno} - spaces around attribute delimiters will be allowed in Slim 2.0. Your code is incompatible."
        else
          delimiter = DELIMITERS[$&]
          @line.slice!(0)
        end
      end

      if delimiter
        boolean_attr_regex = /#{ATTR_NAME}(?=(\s|#{Regexp.escape delimiter}|\Z))/
        end_regex = /\A\s*#{Regexp.escape delimiter}/
      end

      while true
        case @line
        when /\A\s*\*(?=[^\s]+)/
          # Splat attribute
          @line = $'
          attributes << [:slim, :splat, parse_ruby_code(delimiter)]
        when QUOTED_ATTR_REGEX
          # Value is quoted (static)
          @line = $'
          name = $1
          escape = $2.empty?
          quote = $3
          value = parse_quoted_attribute(quote)
          if escape && !options[:escape_quoted_attrs] && value =~ /&(amp|quot|gt|lt);/
            warn "#{options[:file]}:#{@lineno} - quoted attribute value '#{value}' might be double escaped in Slim 2.0. Remove manually escaped entities and set :escape_quoted_attrs => true! :escaped_quoted_attrs is activated on Slim 2.0 by default."
          end
          attributes << [:html, :attr, name,
                         [:escape, options[:escape_quoted_attrs] && escape,
                          [:slim, :interpolate, value]]]
        when CODE_ATTR_REGEX
          # Value is ruby code
          @line = $'
          name = $1
          escape = $2.empty?
          value = parse_ruby_code(delimiter)
          # Remove attribute wrapper which doesn't belong to the ruby code
          # e.g id=[hash[:a] + hash[:b]]
          if value =~ /\A[\[\{]/ && DELIMITERS[$&] == value[-1, 1]
            warn "#{options[:file]}:#{@lineno} - ruby attribute value #{value} with curly braces/brackets is deprecated and unsupported in Slim 2.0. Use parentheses!"
            value = value[1..-2]
          end
          syntax_error!('Invalid empty attribute') if value.empty?
          attributes << [:html, :attr, name, [:slim, :attrvalue, escape, value]]
        else
          if @line =~ QUOTED_ATTR_REGEX_20 || @line =~ CODE_ATTR_REGEX_20
            warn "#{options[:file]}:#{@lineno} - you have spaces around =, this will be interpreted as attribute in Slim 2.0."
          end

          break unless delimiter

          case @line
          when boolean_attr_regex
            # Boolean attribute
            @line = $'
            attributes << [:html, :attr, $1, [:slim, :attrvalue, false, 'true']]
          when end_regex
            # Find ending delimiter
            @line = $'
            break
          else
            # Found something where an attribute should be
            @line.lstrip!
            syntax_error!('Expected attribute') unless @line.empty?

            # Attributes span multiple lines
            @stacks.last << [:newline]
            syntax_error!("Expected closing delimiter #{delimiter}") if @lines.empty?
            next_line
          end
        end
      end

      attributes
    end

    def parse_ruby_code(outer_delimiter)
      code, count, delimiter, close_delimiter = '', 0, nil, nil

      # Attribute ends with space or attribute delimiter
      end_regex = /\A[\s#{Regexp.escape outer_delimiter.to_s}]/

      until @line.empty? || (count == 0 && @line =~ end_regex)
        if @line =~ /\A[,\\]\Z/
          code << @line << "\n"
          expect_next_line
        else
          if count > 0
            if @line[0] == delimiter[0]
              count += 1
            elsif @line[0] == close_delimiter[0]
              count -= 1
            end
          elsif @line =~ DELIMITER_REGEX
            count = 1
            delimiter, close_delimiter = $&, DELIMITERS[$&]
          end
          code << @line.slice!(0)
        end
      end
      syntax_error!("Expected closing delimiter #{close_delimiter}") if count != 0
      code
    end

    def parse_quoted_attribute(quote)
      value, count = '', 0

      until @line.empty? || (count == 0 && @line[0] == quote[0])
        if @line =~ /\A\\\Z/
          value << ' '
          expect_next_line
        else
          if count > 0
            if @line[0] == ?{
              count += 1
            elsif @line[0] == ?}
              count -= 1
            end
          elsif @line =~ /\A#\{/
            value << @line.slice!(0)
            count = 1
          end
          value << @line.slice!(0)
        end
      end

      syntax_error!("Expected closing brace }") if count != 0
      syntax_error!("Expected closing quote #{quote}") if @line[0] != quote[0]
      @line.slice!(0)

      value
    end

    # Helper for raising exceptions
    def syntax_error!(message)
      raise SyntaxError.new(message, options[:file], @orig_line, @lineno,
                            @orig_line && @line ? @orig_line.size - @line.size : 0)
    end

    def expect_next_line
      next_line || syntax_error!('Unexpected end of file')
      @line.strip!
    end
  end
end
