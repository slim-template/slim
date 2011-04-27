module Slim
  # Compiles Slim expressions into Temple::HTML expressions.
  # @api private
  class Compiler < Filter
    set_default_options :auto_escape => true

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

    # Handle conditional comment expression `[:slim, :conditional_comment, conditional, content]`
    #
    # @param [Array] content Temple expression
    # @return [Array] Compiled temple expression
    def on_slim_conditional_comment(condition, content)
      [:multi, [:static, "<!--#{condition}>"], compile(content), [:static, '<![endif]-->']]
    end

    # Handle output expression `[:slim, :output, escape, code, content]`
    #
    # @param [Boolean] escape Escape html
    # @param [String] code Ruby code
    # @param [Array] content Temple expression
    # @return [Array] Compiled temple expression
    def on_slim_output(escape, code, content)
      if empty_exp?(content)
        [:multi, [:escape, escape && options[:auto_escape], [:dynamic, code]], content]
      else
        tmp = tmp_var

        [:multi,
         # Capture the result of the code in a variable. We can't do
         # `[:dynamic, code]` because it's probably not a complete
         # expression (which is a requirement for Temple).
         [:block, "#{tmp} = #{code}"],

         # Capture the content of a block in a separate buffer. This means
         # that `yield` will not output the content to the current buffer,
         # but rather return the output.
         #
         # The capturing can be disabled with the option :disable_capture.
         # Output code in the block writes directly to the output buffer then.
         # Rails handles this by replacing the output buffer for helpers (with_output_buffer - braindead!).
         options[:disable_capture] ? compile(content) : [:capture, tmp_var, compile(content)],

         # Close the block.
         [:block, 'end'],

         # Output the content.
         on_slim_output(escape, tmp, [:multi])]
      end
    end

    # Handle directive expression `[:slim, :directive, type, args]`
    #
    # @param [String] type Directive type
    # @return [Array] Compiled temple expression
    def on_slim_directive(type, args)
      case type
      when 'doctype'
        [:html, :doctype, args]
      else
        raise "Invalid directive #{type}"
      end
    end
  end
end
