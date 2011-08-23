source :rubygems

gemspec

if ENV['TEMPLE'] == 'master'
   gem 'temple', :git => 'git://github.com/judofyr/temple.git'
end

if ENV['RAILS']
  if ENV['RAILS'] == 'master'
    gem 'rails', :git => 'git://github.com/rails/rails.git'
  else
    gem 'rails', "= #{ENV['RAILS']}"
  end
  gem 'sqlite3-ruby'
end
