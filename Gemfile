source :rubygems

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
    gem 'sqlite3-ruby'
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
