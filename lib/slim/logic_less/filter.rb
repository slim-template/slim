module Slim
  # Handle logic less mode
  # This filter can be activated with the option "logic_less"
  # @api private
  class LogicLess < Filter
    define_options :logic_less => true,
                   :dictionary => 'self',
                   :dictionary_access => :wrapped # :symbol, :string, :wrapped

    def initialize(opts = {})
      super
      unless [:string, :symbol, :wrapped].include?(options[:dictionary_access])
        raise ArgumentError, "Invalid dictionary access #{options[:dictionary_access].inspect}"
      end
    end

    def call(exp)
      if options[:logic_less]
        @dict = unique_name
        dictionary = options[:dictionary]
        dictionary = "::Slim::LogicLess::Wrapper.new(#{dictionary})" if options[:dictionary_access] == :wrapped
        [:multi,
         [:code, "#{@dict} = #{dictionary}"],
         super]
      else
        exp
      end
    end

    # Interpret control blocks as sections or inverted sections
    def on_slim_control(name, content)
      if name =~ /\A!\s*(.*)/
        on_slim_inverted_section($1, content)
      else
        on_slim_section(name, content)
      end
    end

    def on_slim_output(escape, name, content)
      raise(Temple::FilterError, 'Output statements with content are forbidden in logic less mode') if !empty_exp?(content)
      [:slim, :output, escape, access(name), content]
    end

    def on_slim_attr(name, escape, value)
      [:slim, :attr, name, escape, access(value)]
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

    protected

    def on_slim_inverted_section(name, content)
      tmp = unique_name
      [:multi,
       [:code, "#{tmp} = #{access name}"],
       [:if, "!#{tmp} || #{tmp}.respond_to?(:empty) && #{tmp}.empty?",
        compile(content)]]
    end

    def on_slim_section(name, content)
      content = compile(content)
      tmp1, tmp2 = unique_name, unique_name

      [:if, "#{tmp1} = #{access name}",
       [:if, "#{tmp1} == true",
        content,
        [:multi,
         # Wrap map in array because maps implement each
         [:code, "#{tmp1} = [#{tmp1}] if #{tmp1}.respond_to?(:has_key?) || !#{tmp1}.respond_to?(:map)"],
         [:code, "#{tmp2} = #{@dict}"],
         [:block, "#{tmp1}.each do |#{@dict}|", content],
         [:code, "#{@dict} = #{tmp2}"]]]]
    end

    private

    def access(name)
      return name if name == 'yield'
      case options[:dictionary_access]
      when :string
        "#{@dict}[#{name.to_s.inspect}]"
      else
        "#{@dict}[#{name.to_sym.inspect}]"
      end
    end
  end
end
