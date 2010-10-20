# encoding: utf-8

require 'temple'
require 'tilt'

begin
  require 'escape_utils'
rescue LoadError
end

module Slim
  def self.version
    Slim::VERSION
  end

  def self.load(file)
    require File.join(File.dirname(__FILE__), 'slim', file)
  end
end

Slim.load 'parser'
Slim.load 'filter'
Slim.load 'end_inserter'
Slim.load 'compiler'
Slim.load 'engine'
Slim.load 'template'
Slim.load 'helpers'

