require 'rubygems'
require 'rake'

require File.join(File.dirname(__FILE__), "lib", "slim")

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "slim"
    gem.version = Slim.version
    gem.rubyforge_project = "slim"
    gem.summary = "Slim is a template language."
    gem.description = "Slim is a template language whose goal is reduce the syntax to the essential parts without becoming cryptic."
    gem.email = "andy@stonean.com"
    gem.homepage = "http://github.com/stonean/slim"
    gem.authors = ["Andrew Stone"]
    gem.add_dependency 'escape_utils'
    gem.add_development_dependency 'jeweler'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.files   = FileList['lib/**/*.rb']
    t.options = ['-r'] # optional
  end
rescue LoadError
  task :yard do
    abort "YARD is not available. In order to run yard, you must: sudo gem install yard"
  end
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install rcov"
  end
end

task :default => 'test'
