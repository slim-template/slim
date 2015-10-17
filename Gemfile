source 'https://rubygems.org/'

gemspec

if ENV['TRAVIS'] || ENV['TEMPLE'] == 'master'
  gem 'temple', github: 'judofyr/temple'
end

if ENV['TILT']
  if ENV['TILT'] == 'master'
    gem 'tilt', github: 'rtomayko/tilt'
  else
    gem 'tilt', "= #{ENV['TILT']}"
  end
end

if ENV['RAILS']
  # we need some smarter test logic for the different Rails versions
  if RUBY_VERSION >= '2.1.0'
    gem 'nokogiri'
  else
    gem 'nokogiri', '~> 1.6.8'
  end

  if ENV['RAILS'] == 'master'
    gem 'rails', github: 'rails/rails'
  else
    gem 'rails', "= #{ENV['RAILS']}"
  end
end

#Choose minitest 4.7.x for sinatra < 1.4.6 or rails 3 and 4.0 otherwise go for newer version
if (ENV['SINATRA'] && ENV['SINATRA'] < '1.4.6') || (ENV['RAILS'] && ENV['RAILS'].match(/^(3|4\.0)/))
  gem 'minitest', '~> 4.7.4'
else
  gem 'minitest', '~> 5.1'
end

#Ruby >= 2.2.0 has removed test/unit from Stdlib
if RUBY_VERSION >= '2.2.0'
  gem 'test-unit', platforms: :mri
end

if RUBY_ENGINE == 'rbx' && !ENV['TRAVIS']
  gem 'psych'
end

if ENV['SINATRA']
  gem 'rack-test'
  if ENV['SINATRA'] == 'master'
    gem 'sinatra', github: 'sinatra/sinatra'
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
  gem 'benchmark-ips'
  gem 'erubis'
  gem 'haml'
end

if ENV['CODECLIMATE_REPO_TOKEN']
  gem 'codeclimate-test-reporter'
end
