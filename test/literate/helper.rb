require 'slim'
require 'slim/grammar'
require 'minitest/autorun'

Slim::Engine.after  Slim::Parser, Temple::Filters::Validator, :grammar => Slim::Grammar
Slim::Engine.before :Pretty, Temple::Filters::Validator

module Helper
  def render(source, options = {}, &block)
    Slim::Template.new(options) { source }.render(self, &block)
  end
end
