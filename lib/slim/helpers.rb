module Slim
  module Helpers
    def list_of(enum, &block)
      enum.map do |i|
        "<li>#{yield(i)}</li>"
      end.join("\n")
    end

    if defined?(EscapeUtils)
      def escape_html(html)
        EscapeUtils.escape_html(html.to_s)
      end
    elsif RUBY_VERSION > '1.9'
      ESCAPE_HTML = {
        '&' => '&amp;',
        '"' => '&quot;',
        '<' => '&lt;',
        '>' => '&gt;',
        '/' => '&#47;',
      }

      def escape_html(html)
        html.to_s.gsub(/[&\"<>\/]/, ESCAPE_HTML)
      end
    else
      def escape_html(html)
        html.to_s.gsub(/&/n, '&amp;').gsub(/\"/n, '&quot;').gsub(/>/n, '&gt;').gsub(/</n, '&lt;').gsub(/\//, '&#47;')
      end
    end

    def escape_html_safe(html)
      html.html_safe? ? html : escape_html(html)
    end

    module_function :escape_html
    module_function :escape_html_safe
  end
end
