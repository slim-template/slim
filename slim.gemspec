# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + '/lib/slim/version'
require 'date'

Gem::Specification.new do |s|
  s.name              = 'slim'
  s.version           = Slim::VERSION
  s.date              = Date.today.to_s
  s.authors           = ['Andrew Stone', 'Fred Wu', 'Daniel Mendler']
  s.email             = ['andy@stonean.com', 'ifredwu@gmail.com', 'mail@daniel-mendler.de']
  s.summary           = 'Slim is a template language.'
  s.description       = 'Slim is a template language whose goal is reduce the syntax to the essential parts without becoming cryptic.'
  s.homepage          = 'http://slim-lang.com/'
  s.extra_rdoc_files  = %w(README.md LICENSE CHANGES)
  s.rdoc_options      = %w(--charset=UTF-8)
  s.rubyforge_project = s.name

  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = %w(lib)

  s.add_runtime_dependency('temple', ['~> 0.5.0'])
  s.add_runtime_dependency('tilt', ['~> 1.3.3'])

  s.add_development_dependency('rake', ['>= 0.8.7'])
  s.add_development_dependency('sass', ['>= 3.1.0'])
  s.add_development_dependency('minitest', ['>= 0'])
  s.add_development_dependency('kramdown', ['>= 0'])
  s.add_development_dependency('creole', ['>= 0'])
  s.add_development_dependency('builder', ['>= 0'])
end
