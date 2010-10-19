# encoding: utf-8

require 'bundler/setup' if defined?(Bundler)
require 'escape_utils'
require 'temple'
require 'tilt'

require 'slim/parser'
require 'slim/compiler'
require 'slim/end_inserter'
require 'slim/engine'
require 'slim/template'
require 'slim/version'

module Slim
  class << self
    def version
      Slim::VERSION
    end

    def escape_html(html)
      EscapeUtils.escape_html(html.to_s)
    end
  end
end
