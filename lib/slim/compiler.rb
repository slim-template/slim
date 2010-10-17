module Slim
  # Compiles Slim expressions into Temple::HTML expressions.
  class Compiler
    def initialize(options = {})
      @options = options
    end

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

    def on_multi(*exps)
      [:multi, *exps.map { |exp| compile(exp) }]
    end

    def on_text(string)
      if string.include?("\#{")
        [:dynamic, '"%s"' % string]
      else
        [:static, string]
      end
    end

    def on_control(code, content)
      [:multi,
        [:block, code],
        compile(content)]
    end

    def on_output(code)
      [:dynamic, code]
    end

    def on_escaped_output(code)
      [:dynamic, "Slim.escape_html((#{code}))"]
    end

    def on_directive(type)
      case type
      when /^doctype/
        [:html, :doctype, $'.strip]
      else
      end
    end

    def on_tag(name, attrs, content)
      attrs = attrs.inject([:html, :attrs]) do |m, (key, value)|
        if value.include?("\#{")
          value = [:dynamic, value]
        else
          value = [:static, value[1..-2]]
        end
        m << [:html, :basicattr, [:static, key], value]
      end

      [:html, :tag, name, attrs, compile(content)]
    end
  end
end

