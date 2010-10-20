begin
  require 'bundler'
  Bundler::GemHelper.install_tasks
rescue Exception => e
end

require 'rake/testtask'

desc 'Run Slim benchmarks! (Default :iterations is 1000)'
task :bench, :iterations do |t, args|
  ruby("benchmarks/run.rb #{args[:iterations]}")
end

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'lib' << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: gem install rcov"
  end
end

task :default => 'test'
