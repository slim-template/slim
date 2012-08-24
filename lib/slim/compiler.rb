module Slim
  # @api private
  class Compiler < Filter
    def call(exp)
      @attr_delimiter, @splat_used = unique_name, false
      exp = compile(exp)
      if @splat_used
        [:multi, [:code, "#{@attr_delimiter} = #{@options[:attr_delimiter].inspect}"], exp]
      else
        exp
      end
    end

    # Handle control expression `[:slim, :control, code, content]`
    #
    # @param [String] code Ruby code
    # @param [Array] content Temple expression
    # @return [Array] Compiled temple expression
    def on_slim_control(code, content)
      [:multi,
        [:code, code],
        compile(content)]
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

    # Handle text expression `[:slim, :text, content]`
    #
    # @param [Array] content Temple expression
    # @return [Array] Compiled temple expression
    def on_slim_text(content)
      compile(content)
    end

    # Handle tag expression `[:slim, :tag, name, attrs, content]`
    #
    # @param [String] name Tag name
    # @param [Array] attrs Temple expression
    # @param [Array] content Temple expression
    # @return [Array] Compiled temple expression
    def on_slim_tag(name, attrs, content = nil)
      if name == '*'
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
      else
        tag = [:html, :tag, name, compile(attrs)]
        content ? (tag << compile(content)) : tag
      end
    end

    # Handle attributes expression `[:slim, :attrs, *attrs]`
    #
    # @param [Array] attrs Array of temple expressions
    # @return [Array] Compiled temple expression
    def on_slim_attrs(*attrs)
      if attrs.any? {|attr| attr[1] == :splat}
        hash, merger, formatter = splat_attributes(attrs)
        [:multi, merger, formatter]
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
                  [:code, "#{value}.flatten!"],
                  [:block, "#{value}.map! do |#{tmp}|",
                   [:case, tmp,
                    ['true', [:code, name]],
                    ['false, nil', [:multi]],
                    [:else, [:code, tmp]]]],
                  [:if, "#{value}.size > 1 && !#{@attr_delimiter}[#{name}]",
                   [:code, "raise(\"Multiple #\{#{name}\} attributes specified\")"]],
                  [:code, "#{hash}[#{name}] = #{value}.compact.join(#{@attr_delimiter}[#{name}].to_s)"]]]

      attr = [:multi,
              [:static, ' '],
              [:dynamic, name],
              [:static, "=#{options[:attr_wrapper]}"],
              [:escape, true, [:dynamic, value]],
              [:static, options[:attr_wrapper]]]
      attr = [:if, "!#{value}.empty?", attr] if options[:remove_empty_attrs]
      enumerator = options[:sort_attrs] ? "#{hash}.sort_by {|#{name},#{value}| #{name} }" : hash
      formatter = [:block, "#{enumerator}.each do |#{name},#{value}|", attr]

      return hash, merger, formatter
    end
  end
end
