# encoding: utf-8

$:.unshift File.dirname(__FILE__)

require 'escape_utils'
require 'slim/compiler'
require 'slim/engine'

module Slim
  class << self
    def version
      '0.5.1'
    end

    def escape_html(html)
      EscapeUtils.escape_html(html)
    end
  end
end
