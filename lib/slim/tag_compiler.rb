module Slim
  # @api private
  class TagCompiler < Filter
    # Handle tag expression `[:slim, :tag, name, attrs, content]`
    #
    # @param [String] name Tag name
    # @param [Array] attrs Temple expression
    # @param [Array] content Temple expression
    # @return [Array] Compiled temple expression
    def on_slim_tag(name, attrs, content = nil)
      if name == '*'
        hash = unique_name
        if content && !empty_exp?(content)
          tmp = unique_name
          [:multi,
           splat_merge(hash, attrs[2..-1]),
           [:code, "#{tmp} = #{hash}.delete('tag') || #{@options[:default_tag].inspect}"],
           [:static, '<'],
           [:dynamic, "#{tmp}"],
           splat_attributes(hash),
           [:static, '>'],
           content,
           [:static, '</'],
           [:dynamic, "#{tmp}"],
           [:static, '>']]
        else
          [:multi,
           splat_merge(hash, attrs[2..-1]),
           [:static, '<'],
           [:dynamic, "#{hash}.delete('tag') || #{@options[:default_tag].inspect}"],
           splat_attributes(hash),
           [:static, '/>']]
        end
      else
        tag = [:html, :tag, name, compile(attrs)]
        content ? (tag << compile(content)) : tag
      end
    end

    # Handle attributes expression `[:slim, :attrs, *attrs]`
    #
    # @param [Array] *attrs Array of temple expressions
    # @return [Array] Compiled temple expression
    def on_slim_attrs(*attrs)
      if attrs.any? {|a| a[0] == :slim && a[1] == :splat}
        hash = unique_name
        [:multi, splat_merge(hash, attrs), splat_attributes(hash)]
      else
        [:html, :attrs, *attrs.map {|a| compile(a) }]
      end
    end

    # Handle attribute expression `[:slim, :attr, escape, code]`
    #
    # @param [Boolean] escape Escape html
    # @param [String] code Ruby code
    # @return [Array] Compiled temple expression
    def on_slim_attr(name, escape, code)
      value = case code
      when 'true'
        [:static, name]
      when 'false', 'nil'
        [:multi]
      else
        tmp = unique_name
        [:multi,
         [:code, "#{tmp} = #{code}"],
         [:case, tmp,
          ['true', [:static, name]],
          ['false, nil', [:multi]],
          [:else,
           [:escape, escape, [:dynamic,
            if delimiter = options[:attr_delimiter][name]
              "#{tmp}.respond_to?(:join) ? #{tmp}.flatten.compact.join(#{delimiter.inspect}) : #{tmp}"
            else
              tmp
            end
           ]]]]]
      end
      [:html, :attr, name, value]
    end

    private

    def splat_merge(hash, attrs)
      tmphash, name, value, tmp = unique_name, unique_name, unique_name, unique_name

      result = [:multi,
                [:code, "#{hash}, #{tmphash} = {}, {}"]]
      attrs.each do |attr|
        result << if attr[0] == :html && attr[1] == :attr
          [:multi, [:capture, tmp, compile(attr[3])], [:code, "(#{tmphash}[#{attr[2].inspect}] ||= []) << #{tmp}"]]
        elsif attr[0] == :slim
          if attr[1] == :attr
            [:code, "(#{tmphash}[#{attr[2].inspect}] ||= []) << #{attr[4]}"]
          elsif attr[1] == :splat
            name, value = unique_name, unique_name
            [:code, "(#{attr[2]}).each {|#{name},#{value}| (#{tmphash}[#{name}.to_s] ||= []) << #{value} }"]
          else
            attr
          end
        else
          attr
        end
      end

      join = [:case, name]
      options[:attr_delimiter].each do |attr, delim|
        join << [attr.inspect, [:code, "#{hash}[#{name}] = #{value}.flatten.compact.join(#{delim.inspect})"]]
      end
      join << [:else,
               [:multi,
                [:code, "#{value}.flatten!"],
                [:if, "#{value}.size == 1",
                 [:code, "#{hash}[#{name}] = #{value}.last"],
                 [:code, "raise(\"Multiple #\{#{name}\} attributes specified\")"]]]]

      result << [:block, "#{tmphash}.each do |#{name},#{value}|",
                 [:multi,
                  [:block, "#{value}.map! do |#{tmp}|",
                   [:case, tmp,
                    ['true', [:code, name]],
                    ['false, nil', [:multi]],
                    [:else, [:code, tmp]]]],
                  join]]
    end

    def splat_attributes(hash)
      name, value = unique_name, unique_name
      attr = [:multi,
              [:static, ' '],
              [:dynamic, name],
              [:static, "=#{options[:attr_wrapper]}"],
              [:escape, true, [:dynamic, value]],
              [:static, options[:attr_wrapper]]]
      attr = [:if, "!#{value}.empty?", attr] if options[:remove_empty_attrs]
      hash = "#{hash}.sort_by {|#{name},#{value}| #{name} }" if options[:sort_attrs]
      [:block, "#{hash}.each do |#{name},#{value}|", attr]
    end
  end
end
