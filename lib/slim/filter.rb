module Slim
  # Base class for Temple filters used in Slim
  #
  # This base filter passes everything through and allows
  # to override only some methods without affecting the rest
  # of the expression.
  #
  # @api private
  class Filter < Temple::HTML::Filter
    # Pass-through handler
    def on_slim_text(content)
      [:slim, :text, compile(content)]
    end

    # Pass-through handler
    def on_slim_smart(content)
      [:slim, :smart, compile(content)]
    end

    # Pass-through handler
    def on_slim_interpolate(string)
      [:slim, :interpolate, string]
    end

    # Pass-through handler
    def on_slim_embedded(type, content)
      [:slim, :embedded, type, compile(content)]
    end

    # Pass-through handler
    def on_slim_control(code, content)
      [:slim, :control, code, compile(content)]
    end

    # Pass-through handler
    def on_slim_output(code, escape, content)
      [:slim, :output, code, escape, compile(content)]
    end
  end
end
