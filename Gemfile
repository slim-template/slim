source :rubygems

gemspec

require File.dirname(__FILE__) + "/lib/slim/env"

if Slim.env.edge?
  gem "temple", :git  => "git://github.com/judofyr/temple.git"
elsif Slim.env.local?
  gem "temple", :path => "/path/to/your/local/temple/repo"
end