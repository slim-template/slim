begin
  require 'bundler'
  Bundler::GemHelper.install_tasks
rescue Exception
end

require 'rake/testtask'

desc 'Run Slim benchmarks! (default parameters slow=false iterations=1000)'
task :bench, :iterations, :slow do
  ruby('benchmarks/run-benchmarks.rb')
end

task 'test' => %w(test:core_and_plugins)

namespace 'test' do
  task 'core_and_plugins' => %w(core logic_less translator)

  Rake::TestTask.new('core') do |t|
    t.libs << 'lib' << 'test/core'
    t.test_files = FileList['test/core/test_*.rb']
    t.verbose = true
  end

  Rake::TestTask.new('logic_less') do |t|
    t.libs << 'lib' << 'test/core'
    t.test_files = FileList['test/logic_less/test_*.rb']
    t.verbose = true
  end

  Rake::TestTask.new('translator') do |t|
    t.libs << 'lib' << 'test/core'
    t.test_files = FileList['test/translator/test_*.rb']
    t.verbose = true
  end

  Rake::TestTask.new('rails') do |t|
    t.libs << 'lib'
    t.test_files = FileList['test/rails/test/test_*.rb']
    t.verbose = true
  end

  begin
    require 'sinatra'
    spec = Gem::Specification.find_by_name('sinatra')
    Rake::TestTask.new('sinatra') do |t|
      # Run Slim integration test in Sinatra
      t.test_files = FileList["#{spec.gem_dir}/test/slim_test.rb"]
      t.verbose = true
    end
  rescue LoadError
    task :sinatra do
      abort 'Sinatra is not available'
    end
  end
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |t|
    t.libs << 'lib' << 'test/slim'
    t.test_files = FileList['test/slim/test_*.rb']
    t.verbose = true
  end
rescue LoadError
  task :rcov do
    abort 'RCov is not available. In order to run rcov, you must: gem install rcov'
  end
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.files = %w(lib/**/*.rb)
  end
rescue LoadError
  task :yard do
    abort 'YARD is not available. In order to run yard, you must: gem install yard'
  end
end

desc "Generate Documentation"
task :doc => :yard

task :default => 'test'
