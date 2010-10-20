# encoding: utf-8

require 'escape_utils'
require 'temple'
require 'tilt'

def slim_file(f)
  File.join(File.dirname(__FILE__), 'slim', f)
end

require slim_file('parser')
require slim_file('filter')
require slim_file('end_inserter')
require slim_file('compiler')
require slim_file('engine')
require slim_file('template')
require slim_file('helpers')

begin
  require 'escape_utils'
rescue LoadError
end

module Slim
  def self.version
    Slim::VERSION
  end
end
