module Slim
  # Compiles Slim expressions into Temple::HTML expressions.
  # @api private
  class Compiler < Filter
    # Handle control expression `[:slim, :control, code, content]`
    #
    # @param [String] ruby code
    # @param [Array] content Temple expression
    # @return [Array] Compiled temple expression
    def on_slim_control(code, content)
      [:multi,
        [:block, code],
        compile!(content)]
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
      tmp1, tmp2 = tmp_var('capture'), tmp_var('capture')

      [:multi,
        # Capture the result of the code in a variable. We can't do
        # `[:dynamic, code]` because it's probably not a complete
        # expression (which is a requirement for Temple).
        [:block, "#{tmp1} = #{code}"],

        # Capture the content of a block in a separate buffer. This means
        # that `yield` will not output the content to the current buffer,
        # but rather return the output.
        [:capture, tmp2,
         compile!(content)],

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

    # Handle tag expression `[:slim, :tag, name, attrs, closed, content]`
    #
    # @param [String] name Tag name
    # @param [Array] attrs Attributes
    # @param [Array] content Temple expression
    # @return [Array] Compiled temple expression
    def on_slim_tag(name, attrs, closed, content)
      [:html, :tag, name, compile!(attrs), closed, compile!(content)]
    end

    # Handle tag attributes expression `[:slim, :attrs, *attrs]`
    #
    # @param [Array] attrs Attributes
    # @return [Array] Compiled temple expression
    def on_slim_attrs(*attrs)
      [:html, :staticattrs, *attrs.map {|k, v| [k.to_s, compile!(v)] }]
    end
  end
end
