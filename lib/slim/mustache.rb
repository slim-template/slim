require 'slim'
require 'slim/mustache/filter'
require 'slim/mustache/parser'
require 'slim/mustache/grammar'

Slim::Engine.replace Slim::Parser, Slim::Mustache::Parser
Slim::Engine.before Slim::Interpolation, Slim::Mustache::Filter
