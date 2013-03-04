module Slim
  # Handlebars/Emberjs mode
  # This filter can be activated with the option "handlebars"
  class Handlebars < Filter
    define_options :handlebars => true

    def call(exp)
      if options[:handlebars]
        exp = compile(exp)
      else
        exp
      end
      exp
    end

    def on_html_attrs(*attrs)
      if attrs.any? { |attr| handlebars?(attr) }
        handlebars_attrs, html_attrs = attrs.partition { |attr| handlebars?(attr) }
        [:multi,
         *handlebars_attrs.map { |attr| [:static, attr[2]] },
         [:html, :attrs,
          *html_attrs.map { |attr| handlebars?(attr) ? [:static, attr[2]] : compile(attr) }]]
      else
        super
      end
    end

    private

    def handlebars?(attr)
      attr[0] == :slim and attr[1] == :handlebars
    end
  end

end