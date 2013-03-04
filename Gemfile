source 'https://rubygems.org/'

gemspec

if ENV['TRAVIS'] || ENV['TEMPLE'] == 'master'
  gem 'temple', :github => 'judofyr/temple'
elsif ENV['TEMPLE_PATH']
  gem 'temple', :path => ENV['TEMPLE_PATH']
end

if ENV['RAILS']
  if ENV['RAILS'] == 'master'
    gem 'rails', :github => 'rails/rails'
  else
    gem 'rails', "= #{ENV['RAILS']}"
  end

  if defined?(JRUBY_VERSION)
    gem 'jdbc-sqlite3'
    gem 'activerecord-jdbc-adapter'
    gem 'activerecord-jdbcsqlite3-adapter'
  else
    gem 'sqlite3'
  end
end

if ENV['SINATRA']
  gem 'rack-test'
  if ENV['SINATRA'] == 'master'
    gem 'sinatra', :github => 'sinatra/sinatra'
  else
    gem 'sinatra', "= #{ENV['SINATRA']}"
  end
end

gem 'rake', '>= 0.8.7'
gem 'sass', '>= 3.1.0'
gem 'minitest'
gem 'kramdown'
gem 'creole'
gem 'builder'
gem 'asciidoctor'

if ENV['TASK'] == 'bench'
  gem 'erubis'
  gem 'haml'
end
