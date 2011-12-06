#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'), File.dirname(__FILE__))

require 'slim'

content = File.read(File.dirname(__FILE__) + '/view.slim')
engine = Slim::Engine.new

1000.times { engine.call(content) }
