# encoding: utf-8

require 'temple'
require 'slim/helpers'
require 'slim/parser'
require 'slim/filter'
require 'slim/end_inserter'
require 'slim/embedded_engine'
require 'slim/compiler'
require 'slim/engine'
require 'slim/template'
require 'slim/version'

module Slim
  def self.version
    VERSION
  end
end
