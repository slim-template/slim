source 'https://rubygems.org/'

gemspec

group :perf do
  gem 'benchmark-ips'
  gem 'erubi'
  gem 'haml'
end

if  ENV['TEMPLE'] == 'master'
  gem 'temple', :github => 'judofyr/temple'
end

if ENV['TILT']
  if ENV['TILT'] == 'master'
    gem 'tilt', :github => 'rtomayko/tilt'
  else
    gem 'tilt', "= #{ENV['TILT']}"
  end
end

if ENV['RAILS']
  # we need some smarter test logic for the different Rails versions
  if ENV['RAILS'] == 'main'
    gem 'rails', :github => 'rails/rails', branch: 'main'
  else
    gem 'rails', "= #{ENV['RAILS']}"
  end

  gem 'slim-rails', require: false
end

gem 'test-unit', '~> 3.5'
gem 'minitest', '~> 5.15'

if ENV['SINATRA']
  if ENV['SINATRA'] == 'master'
    gem 'sinatra', :github => 'sinatra/sinatra'
  else
    gem 'sinatra', :tag => "v#{ENV['SINATRA']}"
  end
end

gem 'rake', '~> 13.0'
gem 'kramdown', '~> 2.4'

if ENV['TASK'] == 'bench'
  gem 'benchmark-ips'
  gem 'erubi'
  gem 'haml'
end

if ENV['CODECLIMATE_REPO_TOKEN']
  gem 'codeclimate-test-reporter'
end
