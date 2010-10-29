module Slim
  # Base class for Temple filters used in Slim
  # @api private
  class Filter < Temple::Filters::BasicFilter
    temple_dispatch :slim

    def on_slim_control(code, content)
      [:slim, :control, code, compile(content)]
    end

    def on_slim_output(code, escape, content)
      [:slim, :output, code, escape, compile(content)]
    end

    def on_slim_tag(name, attrs, closed, content)
      [:slim, :tag, name, attrs, closed, compile(content)]
    end
  end
end
