module Slim
  # @api private
  class SplatAttributes < Filter
    define_options :sort_attrs, :default_tag, :merge_attrs, :attr_quote

    def call(exp)
      @merge_attrs, @splat_used = unique_name, false
      exp = compile(exp)
      if @splat_used
        [:multi, [:code, "#{@merge_attrs} = #{@options[:merge_attrs].inspect}"], exp]
      else
        exp
      end
    end

    # Handle tag expression `[:html, :tag, name, attrs, content]`
    #
    # @param [String] name Tag name
    # @param [Array] attrs Temple expression
    # @param [Array] content Temple expression
    # @return [Array] Compiled temple expression
    def on_html_tag(name, attrs, content = nil)
      return super if name != '*'
      hash, merger, formatter = splat_attributes(attrs[2..-1])
      tmp = unique_name
      tag = [:multi,
             merger,
             [:code, "#{tmp} = #{hash}.delete('tag').to_s"],
             [:if, "#{tmp}.empty?",
              [:code, "#{tmp} = #{@options[:default_tag].inspect}"]],
             [:static, '<'],
             [:dynamic, "#{tmp}"],
             formatter]
      tag << if content
               [:multi,
                [:static, '>'],
                compile(content),
                [:static, '</'],
                [:dynamic, "#{tmp}"],
                [:static, '>']]
             else
               [:static, '/>']
             end
    end

    # Handle attributes expression `[:html, :attrs, *attrs]`
    #
    # @param [Array] attrs Array of temple expressions
    # @return [Array] Compiled temple expression
    def on_html_attrs(*attrs)
      return super if attrs.all? {|attr| attr[1] != :splat}
      hash, merger, formatter = splat_attributes(attrs)
      [:multi, merger, formatter]
    end

    protected

    def splat_attributes(attrs)
      @splat_used = true

      hash, name, value, tmp = unique_name, unique_name, unique_name, unique_name

      merger = [:multi, [:code, "#{hash} = {}"]]
      attrs.each do |attr|
        merger << if attr[0] == :html && attr[1] == :attr
          [:multi,
           [:capture, tmp, compile(attr[3])],
           [:code, "(#{hash}[#{attr[2].inspect}] ||= []) << #{tmp}"]]
        elsif attr[0] == :slim
          if attr[1] == :attr
            [:code, "(#{hash}[#{attr[2].inspect}] ||= []) << (#{attr[4]})"]
          elsif attr[1] == :splat
            [:code, "(#{attr[2]}).each {|#{name},#{value}| (#{hash}[#{name}.to_s] ||= []) << (#{value}) }"]
          else
            attr
          end
        else
          attr
        end
      end

      merger << [:block, "#{hash}.keys.each do |#{name}|",
                 [:multi,
                  [:code, "#{value} = #{hash}[#{name}]"],
                  [:if, "#{@merge_attrs}[#{name}]",
                   [:multi,
                    [:code, "#{value}.flatten!"],
                    [:code, "#{value}.map!(&:to_s)"],
                    [:code, "#{value}.reject!(&:empty?)"],
                    [:if, "#{value}.empty?",
                     [:code, "#{hash}.delete(#{name})"],
                     [:code, "#{hash}[#{name}] = #{value}.join(#{@merge_attrs}[#{name}].to_s)"]]],
                   [:multi,
                    [:if, "#{value}.size > 1",
                     [:code, %{raise("Multiple #\{#{name}\} attributes specified")}]],
                    [:case, "#{value}.first",
                     ['true', [:code, "#{hash}[#{name}] = #{name}"]],
                     ['false, nil', [:code, "#{hash}.delete(#{name})"]],
                     [:else, [:code, "#{hash}[#{name}] = #{value}.first"]]]]]]]

      attr = [:multi,
              [:static, ' '],
              [:dynamic, name],
              [:static, "=#{options[:attr_quote]}"],
              [:escape, true, [:dynamic, value]],
              [:static, options[:attr_quote]]]
      enumerator = options[:sort_attrs] ? "#{hash}.sort_by {|#{name},#{value}| #{name} }" : hash
      formatter = [:block, "#{enumerator}.each do |#{name},#{value}|", attr]

      return hash, merger, formatter
    end
  end
end
