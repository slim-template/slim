require 'slim/handlebars/filter'

# Insert plugin filter into Slim engine chain
Slim::Engine.before(Slim::Splat::Filter, Slim::Handlebars, :handlebars)