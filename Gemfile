source 'https://rubygems.org/'

gemspec

if ENV['TRAVIS'] || ENV['TEMPLE'] == 'master'
  gem 'temple', :github => 'judofyr/temple'
elsif ENV['TEMPLE_PATH']
  gem 'temple', :path => ENV['TEMPLE_PATH']
end

if ENV['TILT']
  if ENV['TILT'] == 'master'
    gem 'opal', :github => 'opal/opal' if RUBY_VERSION > '1.9'
    gem 'tilt', :github => 'rtomayko/tilt'
  else
    gem 'tilt', "= #{ENV['TILT']}"
  end
end

if ENV['RAILS']
  if ENV['RAILS'] == 'master'
    gem 'rails', :github => 'rails/rails'
  else
    gem 'rails', "= #{ENV['RAILS']}"
  end
end

#Choose minitest 4.7.x for sinatra or rails 3 and 4.0 otherwise go for newer version
if ENV['SINATRA'] || (ENV['RAILS'] && !ENV['RAILS'].match(/4\.([1-9])(\..*)?/))
  gem 'minitest', '~> 4.7.4'
else
  gem 'minitest', '~> 5.1'
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
gem 'kramdown'
gem 'creole'
gem 'builder'
gem 'asciidoctor'
gem 'org-ruby'

if ENV['TASK'] == 'bench'
  gem 'erubis'
  gem 'haml'
end
