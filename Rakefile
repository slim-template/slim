begin
  require 'bundler'
  Bundler::GemHelper.install_tasks
rescue Exception => e
end

require 'rake/testtask'

desc 'Run Slim benchmarks! (Default :iterations is 1000)'
task :bench, :iterations, :slow do |t, args|
  ruby("benchmarks/run.rb #{args[:slow]} #{args[:iterations]}")
end

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/slim/**/test_*.rb'
  t.verbose = true
end

Rake::TestTask.new(:integration) do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/integration/**/test_*.rb'
  t.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |t|
    t.libs << 'lib' << 'test'
    t.pattern = 'test/**/test_*.rb'
    t.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: gem install rcov"
  end
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.files = %w(lib/**/*.rb)
  end
rescue LoadError
  task :yard do
    abort "YARD is not available. In order to run yard, you must: gem install yard"
  end
end

desc "Generate Documentation"
task :doc => :yard

task :default => 'test'
