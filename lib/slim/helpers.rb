module Slim
  module Helpers
    def list_of(enum, &block)
      enum.map do |i|
        "<li>#{yield(i)}</li>"
      end.join("\n")
    end

    def escape_html_with_html_safe(html)
      Compiler.options[:use_html_safe] && html.to_s.html_safe? ? html : escape_html(html)
    rescue
      escape_html(html)
    end

    def escape_html(html)
      if defined?(EscapeUtils)
        EscapeUtils.escape_html(html.to_s)
      elsif RUBY_VERSION > '1.9'
        html.to_s.gsub(/[&\"<>\/]/, {
          '&' => '&amp;',
          '"' => '&quot;',
          '<' => '&lt;',
          '>' => '&gt;',
          '/' => '&#47;',
        })
      else
        html.to_s.gsub(/&/n, '&amp;').gsub(/\"/n, '&quot;').gsub(/>/n, '&gt;').gsub(/</n, '&lt;').gsub(/\//, '&#47;')
      end
    end

    module_function :escape_html
    module_function :escape_html_with_html_safe
  end
end
