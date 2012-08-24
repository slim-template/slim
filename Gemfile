source :rubygems

gemspec

if ENV['TRAVIS'] || ENV['TEMPLE'] == 'master'
   gem 'temple', :git => 'git://github.com/judofyr/temple.git'
end

if ENV['RAILS']
  if ENV['RAILS'] == 'master'
    gem 'rails', :git => 'git://github.com/rails/rails.git'
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
