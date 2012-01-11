# encoding: utf-8

require 'rubygems'
require 'minitest/unit'
require 'slim'
require 'slim/grammar'

MiniTest::Unit.autorun

Slim::Engine.after  Slim::Parser, Temple::Filters::Validator, :grammar => Slim::Grammar
Slim::Engine.before Slim::Compiler, Temple::Filters::Validator, :grammar => Slim::Grammar
Slim::Engine.before Temple::HTML::Pretty, Temple::Filters::Validator

class TestSlim < MiniTest::Unit::TestCase
  def setup
    @env = Env.new
  end

  def teardown
    Slim::Sections.set_default_options(:dictionary_access => :wrapped)
  end

  def render(source, options = {}, &block)
    Slim::Template.new(options[:file], options) { source }.render(options[:scope] || @env, &block)
  end

  def assert_html(expected, source, options = {}, &block)
    assert_equal expected, render(source, options, &block)
  end

  def assert_syntax_error(message, source, options = {})
    render(source, options)
    raise 'Syntax error expected'
  rescue Slim::Parser::SyntaxError => ex
    assert_equal message, ex.message
  end

  def assert_ruby_error(error, from, source, options = {})
    render(source, options)
    raise 'Ruby error expected'
  rescue error => ex
    assert_backtrace(ex, from)
  end

  def assert_backtrace(ex, from)
    if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx'
      # HACK: Rubinius stack trace sometimes has one entry more
      if ex.backtrace[0] !~ /^#{Regexp.escape from}:/
        ex.backtrace[1] =~ /^(.*?:\d+):/
        assert_equal from, $1
      end
    else
      ex.backtrace[0] =~ /^(.*?:\d+):/
      assert_equal from, $1
    end
  end

  def assert_ruby_syntax_error(from, source, options = {})
    render(source, options)
    raise 'Ruby syntax error expected'
  rescue SyntaxError => ex
    ex.message =~ /^(.*?:\d+):/
    assert_equal from, $1
  end

  def assert_runtime_error(message, source, options = {})
    render(source, options)
    raise Exception, 'Runtime error expected'
  rescue RuntimeError => ex
    assert_equal message, ex.message
  end
end

class Env
  attr_reader :var, :x

  class ::HtmlSafeString < String
    def html_safe?
      true
    end
  end

  class ::HtmlUnsafeString < String
    def html_safe?
      false
    end
  end

  def initialize
    @var = 'instance'
    @x = 0
  end

  def id_helper
    "notice"
  end

  def hash
    {:a => 'The letter a', :b => 'The letter b'}
  end

  def show_first?(show = false)
    show
  end

  def define_macro(name, &block)
    @macro ||= {}
    @macro[name.to_s] = block
    ''
  end

  def call_macro(name, *args)
    @macro[name.to_s].call(*args)
  end

  def hello_world(text = "Hello World from @env", opts = {})
    text << opts.to_a * " " if opts.any?
    if block_given?
      "#{text} #{yield} #{text}"
    else
      text
    end
  end

  def message(*args)
    args.join(' ')
  end

  def action_path(*args)
    "/action-#{args.join('-')}"
  end

  def in_keyword
    "starts with keyword"
  end

  def evil_method
    "<script>do_something_evil();</script>"
  end

  def method_which_returns_true
    true
  end

  def output_number
    1337
  end

  def succ_x
    @x = @x.succ
  end

end

class ViewEnv
  def output_number
     1337
  end

  def person
    [{:name => 'Joe'}, {:name => 'Jack'}]
  end

  def people
    %w(Andy Fred Daniel).collect{|n| Person.new(n)}
  end

  def cities
    %w{Atlanta Melbourne Karlsruhe}
  end

  def people_with_locations
    array = []
    people.each_with_index do |p,i|
      p.location = Location.new cities[i]
      array << p
    end
    array
  end
end

require 'forwardable'

class Person
  extend Forwardable

  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def location=(location)
    @location = location
  end

  def_delegators :@location, :city
end

class Location
  attr_accessor :city

  def initialize(city)
    @city   = city
  end
end
