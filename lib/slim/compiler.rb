module Slim
  # Compiles Slim expressions into Temple::HTML expressions.
  # @api private
  class Compiler < Filter
    def initialize(options = {})
      super
      @shortcut = {}
      @options[:shortcut].each do |k,v|
        @shortcut[k] = if v =~ /\A([^\s]+)\s+([^\s]+)\Z/
                         [$1, $2]
                       else
                         [@options[:default_tag], v]
                       end
      end
    end

    # Handle control expression `[:slim, :control, code, content]`
    #
    # @param [String] ruby code
    # @param [Array] content Temple expression
    # @return [Array] Compiled temple expression
    def on_slim_control(code, content)
      [:multi,
        [:code, code],
        compile(content)]
    end

    # Handle conditional comment expression
    # `[:slim, :conditional_comment, conditional, content]`
    #
    # @param [Array] content Temple expression
    # @return [Array] Compiled temple expression
    def on_slim_condcomment(condition, content)
      [:html, :comment, [:multi, [:static, "[#{condition}]>"], compile(content), [:static, '<![endif]']]]
    end

    # Handle output expression `[:slim, :output, escape, code, content]`
    #
    # @param [Boolean] escape Escape html
    # @param [String] code Ruby code
    # @param [Array] content Temple expression
    # @return [Array] Compiled temple expression
    def on_slim_output(escape, code, content)
      if empty_exp?(content)
        [:multi, [:escape, escape, [:dynamic, code]], content]
      else
        tmp = unique_name

        [:multi,
         # Capture the result of the code in a variable. We can't do
         # `[:dynamic, code]` because it's probably not a complete
         # expression (which is a requirement for Temple).
         [:block, "#{tmp} = #{code}",

          # Capture the content of a block in a separate buffer. This means
          # that `yield` will not output the content to the current buffer,
          # but rather return the output.
          #
          # The capturing can be disabled with the option :disable_capture.
          # Output code in the block writes directly to the output buffer then.
          # Rails handles this by replacing the output buffer for helpers.
          options[:disable_capture] ? compile(content) : [:capture, unique_name, compile(content)]],

         # Output the content.
         [:escape, escape, [:dynamic, tmp]]]
      end
    end

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
      elsif @shortcut[name]
        tag = [:html, :tag, @shortcut[name][0], compile(attrs)]
        content ? (tag << compile(content)) : tag
      else
        tag = [:html, :tag, name, compile(attrs)]
        content ? (tag << compile(content)) : tag
      end
    end

    # Handle shortcut expression `[:slim, :shortcut, type, value]`
    #
    # @param [String] type Shortcut type
    # @param [String] value Shortcut value
    # @return [Array] Compiled temple expression
    def on_slim_shortcut(type, value)
      [:html, :attr, @shortcut[type][1], [:static, value]]
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
      result = [:multi,
                [:code, "#{hash} = {}"]]
      attrs.each do |attr|
        result << if attr[0] == :html && attr[1] == :attr
          tmp = unique_name
          [:multi, [:capture, tmp, compile(attr[3])], [:code, "#{hash}[#{attr[2].inspect}] = #{tmp}"]]
        elsif attr[0] == :slim
          if attr[1] == :attr
            [:code, "#{hash}[#{attr[2].inspect}] = #{attr[4]}"]
          elsif attr[1] == :splat
            name, value = unique_name, unique_name
            [:code, "(#{attr[2]}).each {|#{name},#{value}| #{hash}[#{name}.to_s] = #{value} }"]
          elsif attr[1] == :shortcut
            [:code, "#{hash}[#{@shortcut[attr[2]][1].inspect}] = #{attr[3].inspect}"]
          else
            attr
          end
        else
          attr
        end
      end
      result
    end

    def splat_attributes(hash)
      name, value = unique_name, unique_name
      hash = "#{hash}.sort_by {|#{name},#{value}| #{name}.to_s }" if options[:sort_attrs]
      attr = [:multi,
              [:static, ' '],
              [:dynamic, name],
              [:static, "=#{options[:attr_wrapper]}"],
              [:escape, true, [:dynamic, value]],
              [:static, options[:attr_wrapper]]]
      if options[:remove_empty_attrs]
        attr = [:multi,
                [:code, "#{value} = #{value}.to_s"],
                [:if, "!#{value}.empty?",
                 attr]]
      end
      [:block, "#{hash}.each do |#{name},#{value}|", attr]
    end
  end
end
