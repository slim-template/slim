# encoding: utf-8

$:.unshift File.dirname(__FILE__)

require 'bundler/setup'
require 'escape_utils'
require 'slim/compiler'
require 'slim/engine'

module Slim
  class << self
    def version
      '0.6.0'
    end

    def escape_html(html)
      EscapeUtils.escape_html(html.to_s)
    end
  end
end
