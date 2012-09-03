require 'slim'
require 'slim/logic_less/filter'
require 'slim/logic_less/wrapper'

# Insert plugin filter into Slim engine chain
Slim::Engine.after(Slim::Interpolation, Slim::LogicLess, :logic_less, :dictionary, :dictionary_access)
