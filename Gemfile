source :rubygems

gemspec

if ENV["SLIM_ENV"] == "edge"
  gem "temple", :git  => "git://github.com/judofyr/temple.git"
elsif ENV["SLIM_ENV"] == "local"
  gem "temple", :path => "/path/to/my/local/temple/repo"
end