module Slim
  module Splat
    # @api private
    class Builder
      def initialize(options)
        @options = options
        @attrs = {}
      end

      def code_attr(name, escape, value)
        if delim = @options[:merge_attrs][name]
          value = Array === value ? value.join(delim) : value.to_s
          attr(name, escape ? Temple::Utils.escape_html(value) : value) unless value.empty?
        elsif @options[:hyphen_attrs].include?(name) && Hash === value
          hyphen_attr(name, escape, value)
        else
          case value
          when false, nil
            # Boolean false attribute
            return
          when true
            # Boolean true attribute
            value = ''
          else
            value = value.to_s
          end
          attr(name, escape ? Temple::Utils.escape_html(value) : value)
        end
      end

      def splat_attrs(splat)
        splat.each do |name, value|
          code_attr(name.to_s, true, value)
        end
      end

      def attr(name, value)
        if @attrs[name]
          if delim = @options[:merge_attrs][name]
            @attrs[name] << delim << value
          else
            raise("Multiple #{name} attributes specified")
          end
        else
          @attrs[name] = value
        end
      end

      def build_tag
        tag = @attrs.delete('tag').to_s
        tag = @options[:default_tag] if tag.empty?
        if block_given?
          "<#{tag}#{build_attrs}>#{yield}</#{tag}>"
        else
          "<#{tag}#{build_attrs} />"
        end
      end

      def build_attrs
        attrs = @options[:sort_attrs] ? @attrs.sort_by(&:first) : @attrs
        attrs.map do |k, v|
          " #{k}=#{@options[:attr_quote]}#{v}#{@options[:attr_quote]}"
        end.join
      end

      private

      def hyphen_attr(name, escape, value)
        if Hash === value
          value.each do |n, v|
            hyphen_attr("#{name}-#{n.to_s.gsub('_', '-')}", escape, v)
          end
        else
          attr(name, escape ? Temple::Utils.escape_html(value) : value.to_s)
        end
      end
    end
  end
end
