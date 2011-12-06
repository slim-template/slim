#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'), File.dirname(__FILE__))

require 'slim'
require 'complex_view'

content = File.read(File.dirname(__FILE__) + '/view.slim')
slim = Slim::Template.new { content }
view  = ComplexView.new

10000.times { slim.render(view) }
