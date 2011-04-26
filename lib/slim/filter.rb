module Slim
  # Base class for Temple filters used in Slim
  #
  # This base filter passes everything through and allows
  # to override only some methods without affecting the rest
  # of the expression.
  #
  # @api private
  class Filter < Temple::Filter
    # Dispatch on_slim_*
    temple_dispatch :slim

    def on_slim_control(code, content)
      [:slim, :control, code, compile(content)]
    end

    def on_slim_comment(content)
      [:slim, :comment, compile(content)]
    end

    def on_slim_conditional_comment(condition, content)
      [:slim, :conditional_comment, condition, compile(content)]
    end

    def on_slim_output(code, escape, content)
      [:slim, :output, code, escape, compile(content)]
    end

    def on_slim_tag(name, attrs, closed, content)
      [:slim, :tag, name, compile(attrs), closed, compile(content)]
    end

    def on_slim_attrs(*attrs)
      [:slim, :attrs, *attrs.map {|attr| compile(attr) }]
    end

    def on_slim_attr(name, value)
      [:slim, :attr, name, compile(value)]
    end
  end
end
