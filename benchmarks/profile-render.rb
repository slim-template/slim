#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'), File.dirname(__FILE__))

require 'slim'
require 'context'

content = File.read(File.dirname(__FILE__) + '/view.slim')
slim = Slim::Template.new { content }
context = Context.new

10000.times { slim.render(context) }
