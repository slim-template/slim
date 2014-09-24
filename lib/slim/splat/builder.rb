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
          attr(name, escape ? Temple::Utils.escape_html_safe(value, @options[:use_html_safe]) : value) unless value.empty?
        elsif @options[:hyphen_attrs].include?(name) && Hash === value
          hyphen_attr(name, escape, value)
        elsif value != false && value != nil
          attr(name, value != true && escape ? Temple::Utils.escape_html_safe(value, @options[:use_html_safe]) : value)
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
            @attrs[name] << delim << value.to_s
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
          if v == true
            if @options[:format] == :xhtml
              " #{k}=#{@options[:attr_quote]}#{@options[:attr_quote]}"
            else
              " #{k}"
            end
          else
            " #{k}=#{@options[:attr_quote]}#{v}#{@options[:attr_quote]}"
          end
        end.join
      end

      private

      def hyphen_attr(name, escape, value)
        if Hash === value
          value.each do |n, v|
            hyphen_attr("#{name}-#{n.to_s.gsub('_', '-')}", escape, v)
          end
        else
          attr(name, value != true && escape ? Temple::Utils.escape_html_safe(value, @options[:use_html_safe]) : value)
        end
      end
    end
  end
end
