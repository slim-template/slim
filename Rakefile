begin
  require 'bundler/setup'
  Bundler::GemHelper.install_tasks
rescue Exception
end

require 'rake/testtask'

task 'test' => %w(test:core test:literate test:logic_less test:translator test:smart test:include)

namespace 'test' do
  Rake::TestTask.new('core') do |t|
    t.libs << 'lib' << 'test/core'
    t.test_files = FileList['test/core/test_*.rb']
    t.warning = true
    #t.ruby_opts << '-w' << '-v'
  end

  Rake::TestTask.new('literate') do |t|
    t.libs << 'lib' << 'test/literate'
    t.test_files = FileList['test/literate/run.rb']
    t.warning = true
  end

  Rake::TestTask.new('logic_less') do |t|
    t.libs << 'lib' << 'test/core'
    t.test_files = FileList['test/logic_less/test_*.rb']
    t.warning = true
  end

  Rake::TestTask.new('translator') do |t|
    t.libs << 'lib' << 'test/core'
    t.test_files = FileList['test/translator/test_*.rb']
    t.warning = true
  end

  Rake::TestTask.new('smart') do |t|
    t.libs << 'lib' << 'test/core'
    t.test_files = FileList['test/smart/test_*.rb']
    t.warning = true
  end

  Rake::TestTask.new('include') do |t|
    t.libs << 'lib' << 'test/core'
    t.test_files = FileList['test/include/test_*.rb']
    t.warning = true
  end

  Rake::TestTask.new('rails') do |t|
    t.libs << 'lib'
    t.test_files = FileList['test/rails/test/test_*.rb']
    t.warning = true
  end

  Rake::TestTask.new('sinatra') do |t|
    t.libs << 'lib'
    t.test_files = FileList['test/sinatra/test_*.rb']

    # Copied from test task in Sinatra project to mimic their approach
    t.ruby_opts = ['-r rubygems'] if defined? Gem
    t.ruby_opts << '-I.'
    t.warning = true
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

desc 'Generate Documentation'
task doc: :yard

task default: 'test'
