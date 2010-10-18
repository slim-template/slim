# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "version"

Gem::Specification.new do |s|
  s.name              = "slim"
  s.version           = Slim::VERSION
  s.date              = Date.today.to_s
  s.authors           = ["Andrew Stone", "Fred Wu"]
  s.email             = ["andy@stonean.com", "ifredwu@gmail.com"]
  s.summary           = %q{Slim is a template language.}
  s.description       = %q{Slim is a template language whose goal is reduce the syntax to the essential parts without becoming cryptic.}
  s.homepage          = %q{http://github.com/stonean/slim}
  s.extra_rdoc_files  = ["README.md"]
  s.rdoc_options      = ["--charset=UTF-8"]
  s.require_paths     = ["lib"]
  s.rubyforge_project = s.name

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency(%q<escape_utils>, [">= 0.1.8"])
  s.add_runtime_dependency(%q<temple>, [">= 0.1.2"])
  s.add_runtime_dependency(%q<tilt>, ["~> 1.1"])
  s.add_development_dependency(%q<rake>, [">= 0.8.7"])
  s.add_development_dependency(%q<haml>, [">= 0"])
  s.add_development_dependency(%q<erubis>, [">= 0"])
  s.add_development_dependency(%q<minitest>, [">= 0"]) if RUBY_VERSION < '1.9'
end
