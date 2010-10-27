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
      type, *args = exp
      if respond_to?("on_#{type}")
        send("on_#{type}", *args)
      else
        exp
      end
    end

    def on_slim(type, *args)
      if respond_to?("on_slim_#{type}")
        send("on_slim_#{type}", *args)
      else
        [:slim, type, *args]
      end
    end

    def on_slim_control(code, content)
      [:slim, :control, code, compile(content)]
    end

    def on_slim_output(code, escape, content)
      [:slim, :output, code, escape, compile(content)]
    end

    def on_slim_tag(name, attrs, content)
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
