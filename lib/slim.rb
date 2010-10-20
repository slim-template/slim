# encoding: utf-8

require 'escape_utils'
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

  def self.lib(f)
    File.join(File.dirname(__FILE__), 'slim', f)
  end
end

require Slim.lib('parser')
require Slim.lib('filter')
require Slim.lib('end_inserter')
require Slim.lib('compiler')
require Slim.lib('engine')
require Slim.lib('template')
require Slim.lib('helpers')

