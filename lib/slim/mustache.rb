require 'slim'
require 'slim/mustache/filter'
require 'slim/mustache/parser'
require 'slim/mustache/grammar'

Slim::Engine.before Slim::Interpolation, Slim::Mustache::Filter

