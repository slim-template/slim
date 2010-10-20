# encoding: utf-8

require 'bundler/setup' if defined?(Bundler)
require 'escape_utils'
require 'temple'
require 'tilt'

require 'slim/parser'
require 'slim/filter'
require 'slim/end_inserter'
require 'slim/compiler'
require 'slim/engine'
require 'slim/template'
require 'slim/helpers'

begin
  require 'escape_utils'
rescue LoadError
end

module Slim
  def self.version
    Slim::VERSION
  end
end
