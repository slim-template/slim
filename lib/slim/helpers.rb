module Slim
  # Slim helper functions
  #
  # @api public
  module Helpers
    # Iterate over `Enumerable` object
    # yielding each element to a Slim block
    # and putting the result into `<li>` elements.
    # For example:
    #
    #     = list_of([1,2]) do |i|
    #       = i
    #
    # Produces:
    #
    #     <li>1</li>
    #     <li>2</li>
    #
    # @param enum [Enumerable] The enumerable objects to iterate over
    # @yield [item] A block which contains Slim code that goes within list items
    # @yieldparam item An element of `enum`
    # @api public
    def list_of(enum, &block)
      list = enum.map do |i|
        "<li>#{yield(i)}</li>"
      end.join("\n")
      list.respond_to?(:html_safe) ? list.html_safe : list
    end

    # Returns an escaped copy of `html`.
    # Strings which are declared as html_safe are not escaped.
    #
    # @param html [String] The string to escape
    # @return [String] The escaped string
    # @api public
    def escape_html_safe(html)
      html.html_safe? ? html : escape_html(html)
    end

    if defined?(EscapeUtils)
      # Returns an escaped copy of `html`.
      #
      # @param html [String] The string to escape
      # @return [String] The escaped string
      # @api public
      def escape_html(html)
        EscapeUtils.escape_html(html.to_s)
      end
    elsif RUBY_VERSION > '1.9'
      # Used by escape_html
      # @api private
      ESCAPE_HTML = {
        '&' => '&amp;',
        '"' => '&quot;',
        '<' => '&lt;',
        '>' => '&gt;',
        '/' => '&#47;',
      }.freeze

      # Returns an escaped copy of `html`.
      #
      # @param html [String] The string to escape
      # @return [String] The escaped string
      # @api public
      def escape_html(html)
        html.to_s.gsub(/[&\"<>\/]/, ESCAPE_HTML)
      end
    else
      # Returns an escaped copy of `html`.
      #
      # @param html [String] The string to escape
      # @return [String] The escaped string
      # @api public
      def escape_html(html)
        html.to_s.gsub(/&/n, '&amp;').gsub(/\"/n, '&quot;').gsub(/>/n, '&gt;').gsub(/</n, '&lt;').gsub(/\//, '&#47;')
      end
    end

    module_function :escape_html, :escape_html_safe
  end
end
