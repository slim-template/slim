module Slim
  # Handle logic less mode
  # This filter can be activated with the option "logic_less"
  # @api private
  class LogicLess < Filter
    define_options :logic_less => true,
                   :dictionary => 'self'

    define_deprecated_options :dictionary_access

    def call(exp)
      if options[:logic_less]
        @context = unique_name
        [:multi,
         [:code, "#{@context} = ::Slim::LogicLess::Context.new(#{options[:dictionary]})"],
         super]
      else
        exp
      end
    end

    # Interpret control blocks as sections or inverted sections
    def on_slim_control(name, content)
      method =
        if name =~ /\A!\s*(.*)/
          name = $1
          'inverted_section'
        else
          'section'
        end
      [:multi,
       [:block, "#{@context}.#{method}(#{name.to_sym.inspect}) do",
        compile(content)]]
    end

    def on_slim_output(escape, name, content)
      raise(Temple::FilterError, 'Output statements with content are forbidden in logic less mode') if !empty_exp?(content)
      [:slim, :output, escape, access(name), content]
    end

    def on_slim_attrvalue(escape, value)
      [:slim, :attrvalue, escape, access(value)]
    end

    def on_slim_splat(code)
      [:slim, :splat, access(code)]
    end

    def on_dynamic(code)
      raise Temple::FilterError, 'Embedded code is forbidden in logic less mode'
    end

    def on_code(code)
      raise Temple::FilterError, 'Embedded code is forbidden in logic less mode'
    end

    private

    def access(name)
      name == 'yield' ? name : "#{@context}[#{name.to_sym.inspect}]"
    end
  end
end
