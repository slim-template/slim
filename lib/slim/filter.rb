module Slim
  class Filter
    include Temple::Utils

    def compile(exp)
      if exp[0] == :slim
        _, type, *args = exp
      else
        type, *args = exp
      end

      if respond_to?("on_#{type}")
        send("on_#{type}", *args)
      else
        exp
      end
    end

    def on_control(code, content)
      [:slim, :control, code, compile(content)]
    end

    def on_tag(name, attrs, content)
      [:slim, :tag, name, attrs, compile(content)]
    end

    def on_multi(*exps)
      [:multi, *exps.map { |exp| compile(exp) }]
    end
  end

  class Debugger < Filter
    def compile(exp)
      puts exp.inspect
      exp
    end
  end
end
