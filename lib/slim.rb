# encoding: utf-8

require 'temple'
require 'tilt'

begin
  require 'escape_utils'
rescue LoadError
end

require 'slim/parser'
require 'slim/end_inserter'
require 'slim/compiler'
require 'slim/engine'
require 'slim/template'

module Slim
  class << self
    def version
      Slim::VERSION
    end

    if defined?(EscapeUtils)
      def escape_html(html)
        EscapeUtils.escape_html(html.to_s)
      end
    else
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
    end
  end
end
