source :rubygems

gemspec

if path = ENV['SLIM_USE_TEMPLE']
  if path == 'edge'
    gem 'temple', :git => 'git://github.com/judofyr/temple.git'
  else
    gem 'temple', :path => path
  end
end

group :integration do
  gem 'rails', '~> 3.0.3'
  gem 'sqlite3-ruby'
end