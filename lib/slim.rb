# encoding: utf-8

$:.unshift File.dirname(__FILE__)

require 'slim/precompiler'
require 'slim/engine'

module Slim
  class << self
    def version
      '0.0.1'
    end
  end
end
