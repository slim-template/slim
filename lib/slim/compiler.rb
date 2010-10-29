module Slim
  # Compiles Slim expressions into Temple::HTML expressions.
  # @api private
  class Compiler < Filter
    # Handle text expression `[:slim, :text, string]`
    #
    # @param [String] string Static text
    # @return [Array] Compiled temple expression
    def on_slim_text(string)
      # Interpolate variables in text (#{variable}).
      # Split the text into multiple dynamic and static parts.
      block = [:multi]
      until string.empty?
        case string
        when /^\\(\#\{[^\}]*\})/
          # Escaped interpolation
          block << [:static, $1]
        when /^\#\{([^\}]*)\}/
          # Interpolation
          block << [:escape, :dynamic, $1]
        when /^([^\#]+|\#)/
          # Static text
          block << [:static, $&]
        end
        string = $'
      end
      block
    end

    # Handle control expression `[:slim, :control, code, content]`
    #
    # @param [String] ruby code
    # @param [Array] content Temple expression
    # @return [Array] Compiled temple expression
    def on_slim_control(code, content)
      [:multi,
        [:block, code],
        compile(content)]
    end

    # Handle output expression `[:slim, :output, escape, code, content]`
    #
    # @param [Boolean] escape Escape html
    # @param [String] code Ruby code
    # @param [Array] content Temple expression
    # @return [Array] Compiled temple expression
    def on_slim_output(escape, code, content)
      if empty_exp?(content)
        [:multi, escape ? [:escape, :dynamic, code] : [:dynamic, code], content]
      else
        on_slim_output_block(escape, code, content)
      end
    end

    # Handle output expression `[:slim, :output, escape, code, content]`
    # if content is not empty.
    #
    # @param [Boolean] escape Escape html
    # @param [String] code Ruby code
    # @param [Array] content Temple expression
    # @return [Array] Compiled temple expression
    def on_slim_output_block(escape, code, content)
      tmp1, tmp2 = tmp_var, tmp_var

      [:multi,
        # Capture the result of the code in a variable. We can't do
        # `[:dynamic, code]` because it's probably not a complete
        # expression (which is a requirement for Temple).
        [:block, "#{tmp1} = #{code}"],

        # Capture the content of a block in a separate buffer. This means
        # that `yield` will not output the content to the current buffer,
        # but rather return the output.
        [:capture, tmp2,
         compile(content)],

        # Make sure that `yield` returns the output.
        [:block, tmp2],

        # Close the block.
        [:block, 'end'],

        # Output the content.
        on_slim_output(escape, tmp1, [:multi])]
    end

    # Handle directive expression `[:slim, :directive, type]`
    #
    # @param [String] type Directive type
    # @return [Array] Compiled temple expression
    def on_slim_directive(type)
      if type =~ /^doctype/
        [:html, :doctype, $'.strip]
      end
    end

    # Handle tag expression `[:slim, :tag, name, attrs, content]`
    #
    # @param [String] name Tag name
    # @param [Array] attrs Attributes
    # @param [Array] content Temple expression
    # @return [Array] Compiled temple expression
    def on_slim_tag(name, attrs, content)
      attrs = attrs.inject([]) do |m, (key, dynamic, value)|
        value = if dynamic
                  [:escape, :dynamic, value]
                else
                  on_slim_text(value)
                end
        m << [[:static, key.to_s], value]
      end

      # TODO: last argument false = tag is explicitly closed
      # TODO: Implement support for explicitly closed tags
      # Syntax like in haml (tag(attrs)/)?
      [:html, :tag, name, attrs, compile(content), false]
    end

    private

    # Generate unique temporary variable name
    #
    # @return [String] Variable name
    def tmp_var
      @tmp_var ||= 0
      "_slimtmp#{@tmp_var += 1}"
    end
  end
end
