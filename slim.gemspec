# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + '/lib/slim/version'
require 'date'

Gem::Specification.new do |s|
  s.name              = 'slim'
  s.version           = Slim::VERSION
  s.date              = Date.today.to_s
  s.authors           = ['Daniel Mendler', 'Andrew Stone', 'Fred Wu']
  s.email             = ['mail@daniel-mendler.de', 'andy@stonean.com', 'ifredwu@gmail.com']
  s.summary           = 'Slim is a template language.'
  s.description       = 'Slim is a template language whose goal is reduce the syntax to the essential parts without becoming cryptic.'
  s.homepage          = 'http://slim-lang.com/'
  s.rubyforge_project = s.name

  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = %w(lib)

  s.add_runtime_dependency('temple', ['~> 0.6.3'])
  s.add_runtime_dependency('tilt', ['~> 1.3', '>= 1.3.3'])
end
