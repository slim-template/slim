# encoding: utf-8

require 'bundler/setup' if defined?(Bundler)
require 'temple'
require 'tilt'
require 'escape_utils'
require File.dirname(__FILE__) + '/slim/parser'
require File.dirname(__FILE__) + '/slim/end_inserter'
require File.dirname(__FILE__) + '/slim/compiler'
require File.dirname(__FILE__) + '/slim/engine'
require File.dirname(__FILE__) + '/slim/template'

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
