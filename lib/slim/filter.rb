module Slim
  # Base class for Temple filters used in Slim
  # @api private
  class Filter < Temple::Filter
    # Dispatch on_slim_*
    temple_dispatch :slim

    def on_slim_control(code, content)
      [:slim, :control, code, compile!(content)]
    end

    def on_slim_comment(content)
      [:slim, :comment, compile!(content)]
    end

    def on_slim_output(code, escape, content)
      [:slim, :output, code, escape, compile!(content)]
    end

    def on_slim_tag(name, attrs, closed, content)
      [:slim, :tag, name, compile!(attrs), closed, compile!(content)]
    end

    def on_slim_attrs(*attrs)
      [:slim, :attrs, *attrs.map {|k, v| [k, compile!(v)] }]
    end

    # Generate unique temporary variable name
    #
    # @return [String] Variable name
    def tmp_var(prefix)
      @tmp_var ||= 0
      "_slim#{prefix}#{@tmp_var += 1}"
    end
  end
end
