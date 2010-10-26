module Slim
  # Base class for Temple filters used in Slim
  # @api private
  class Filter
    include Temple::Utils

    DEFAULT_OPTIONS = {}

    def initialize(options = {})
      @options = DEFAULT_OPTIONS.merge(options)
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

    def on_control(code, content)
      [:slim, :control, code, compile(content)]
    end

    def on_output(code, escape, content)
      [:slim, :output, code, escape, compile(content)]
    end

    def on_tag(name, attrs, content)
      [:slim, :tag, name, attrs, compile(content)]
    end

    def on_multi(*exps)
      [:multi, *exps.map { |exp| compile(exp) }]
    end
  end

  # Simple filter which prints Temple expression
  # @api private
  class Debugger < Filter
    def compile(exp)
      puts @options[:prefix] if @options[:prefix]
      puts exp.inspect
      puts
      exp
    end
  end
end
