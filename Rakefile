begin
  require 'bundler'
  Bundler::GemHelper.install_tasks
rescue Exception => e
end

require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

desc 'Run Slim benchmarks! (Default :iterations is 1000)'
task :bench, :iterations do |t, args|
  ENV["SLIM_BENCH_ITERATIONS"] = args[:iterations]
  require 'benchmarks/run'
end

task :default => 'test'
