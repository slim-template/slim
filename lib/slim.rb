# encoding: utf-8

$:.unshift File.dirname(__FILE__)

require 'bundler/setup'
require 'temple'
require 'tilt'
require 'escape_utils'
require 'slim/parser'
require 'slim/end_inserter'
require 'slim/compiler'
require 'slim/engine'
require 'slim/template'

module Slim
  class << self
    def version
      '0.6.0.beta.3'
    end

    def escape_html(html)
      EscapeUtils.escape_html(html.to_s)
    end
  end
end
