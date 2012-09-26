module Slim
  # @api private
  class BooleanAttributes < Filter
    define_options :attr_delimiter

    # Handle attributes expression `[:html, :attrs, *attrs]`
    #
    # @param [Array] attrs Array of temple expressions
    # @return [Array] Compiled temple expression
    def on_html_attrs(*attrs)
      [:multi, *attrs.map {|a| compile(a) }]
    end

    # Handle attribute expression `[:slim, :attr, escape, code]`
    #
    # @param [Boolean] escape Escape html
    # @param [String] code Ruby code
    # @return [Array] Compiled temple expression
    def on_html_attr(name, value)
      unless value[0] == :slim && value[1] == :attrvalue
        @attr = name
        return super
      end

      escape, code = value[2], value[3]
      case code
      when 'true'
        [:html, :attr, name, [:static, name]]
      when 'false', 'nil'
        [:multi]
      else
        tmp = unique_name
        conds = [:case, tmp,
                 ['true', [:html, :attr, name, [:static, name]]],
                 ['false, nil', [:multi]]]
        if delimiter = options[:attr_delimiter][name]
          conds << ['Array',
                    [:multi,
                     [:code, "#{tmp} = #{tmp}.flatten.compact.join(#{delimiter.inspect})"],
                     [:if, "!#{tmp}.empty?",
                      [:html, :attr, name, [:escape, escape, [:dynamic, tmp]]]]]]
        end
        conds << [:else, [:html, :attr, name, [:escape, escape, [:dynamic, tmp]]]]
        [:multi, [:code, "#{tmp} = (#{code})"], conds]
      end
    end

    # Handle attribute expression `[:slim, :attrvalue, escape, code]`
    #
    # @param [Boolean] escape Escape html
    # @param [String] code Ruby code
    # @return [Array] Compiled temple expression
    def on_slim_attrvalue(escape, code)
      tmp = unique_name
      [:multi,
       [:code, "#{tmp} = #{code}"],
       [:escape, escape,
        [:dynamic,
         if delimiter = options[:attr_delimiter][@attr]
           "Array === #{tmp} ? #{tmp}.flatten.compact.join(#{delimiter.inspect}) : #{tmp}"
         else
           tmp
         end
        ]]]
    end
  end
end
