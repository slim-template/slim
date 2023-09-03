begin
  require 'simplecov'
  SimpleCov.start
rescue LoadError
end

require 'minitest/autorun'
require 'slim'
require 'slim/grammar'

Slim::Engine.after  Slim::Parser, Temple::Filters::Validator, grammar: Slim::Grammar
Slim::Engine.before :Pretty, Temple::Filters::Validator

class TestSlim < Minitest::Test
  def setup
    @env = Env.new
  end

  def render(source, options = {}, &block)
    scope = options.delete(:scope)
    locals = options.delete(:locals)
    Slim::Template.new(options[:file], options) { source }.render(scope || @env, locals, &block)
  end

  class HtmlSafeString < String
    def html_safe?
      true
    end

    def to_s
      self
    end
  end

  def with_html_safe
    String.send(:define_method, :html_safe?) { false }
    String.send(:define_method, :html_safe) { HtmlSafeString.new(self) }
    yield
  ensure
    String.send(:undef_method, :html_safe?) if String.method_defined?(:html_safe?)
    String.send(:undef_method, :html_safe) if String.method_defined?(:html_safe)
  end

  def assert_html(expected, source, options = {}, &block)
    assert_equal expected, render(source, options, &block)
  end

  def assert_syntax_error(message, source, options = {})
    render(source, options)
    raise 'Syntax error expected'
  rescue Slim::Parser::SyntaxError => ex
    assert_equal message, ex.message
    message =~ /([^\s]+), Line (\d+)/
    assert_backtrace ex, "#{$1}:#{$2}"
  end

  def assert_ruby_error(error, from, source, options = {})
    render(source, options)
    raise 'Ruby error expected'
  rescue error => ex
    assert_backtrace(ex, from)
  end

  def assert_backtrace(ex, from)
    ex.backtrace[0] =~ /([^\s]+:\d+)/
    assert_equal from, $1
  end

  def assert_ruby_syntax_error(from, source, options = {})
    render(source, options)
    raise 'Ruby syntax error expected'
  rescue SyntaxError => ex
    ex.message =~ /([^\s]+:\d+):/
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

  def initialize
    @var = 'instance'
    @x = 0
  end

  def id_helper
    "notice"
  end

  def hash
    {a: 'The letter a', b: 'The letter b'}
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
    text = text + (opts.to_a * " ") if opts.any?
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
    [{name: 'Joe'}, {name: 'Jack'}]
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
