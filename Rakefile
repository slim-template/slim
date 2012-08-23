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

task 'test' => %w(test:core test:logic_less test:translator)

namespace 'test' do
  Rake::TestTask.new('core') do |t|
    t.libs << 'lib' << 'test/slim'
    t.test_files = FileList['test/slim/test_*.rb']
    t.verbose = true
  end

  Rake::TestTask.new('logic_less') do |t|
    t.libs << 'lib' << 'test/slim'
    t.test_files = FileList['test/slim/logic_less/test_*.rb']
    t.verbose = true
  end

  Rake::TestTask.new('translator') do |t|
    t.libs << 'lib' << 'test/slim'
    t.test_files = FileList['test/slim/translator/test_*.rb']
    t.verbose = true
  end

  Rake::TestTask.new('rails') do |t|
    t.libs << 'lib'
    t.test_files = FileList['test/rails/test/test_*.rb']
    t.verbose = true
  end

  task 'ci' do |t|
    Rake::Task[ENV['TASK']].execute
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
