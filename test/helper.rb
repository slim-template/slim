# encoding: utf-8

require 'rubygems'
require 'minitest/unit'

MiniTest::Unit.autorun

require File.dirname(__FILE__) + '/../lib/slim'

class TestSlim < MiniTest::Unit::TestCase
  def setup
    @env = Env.new
  end

  def teardown
    String.send(:undef_method, :html_safe?) if String.method_defined?(:html_safe?)
    Slim::Filter::DEFAULT_OPTIONS.delete(:use_html_safe)
  end

  def assert_html(expected, source, options = {})
    assert_equal expected, Slim::Template.new(options[:file], options) { source }.render(@env)
  end

  def assert_syntax_error(message, source, options = {})
    Slim::Template.new(options[:file], options) { source }.render(@env)
    raise 'Syntax error expected'
  rescue Slim::Parser::SyntaxError => ex
    assert_equal message, ex.message
  end

  def assert_ruby_error(error, from, source, options = {})
    Slim::Template.new(options[:file], options) { source }.render(@env)
    raise 'Ruby error expected'
  rescue error => ex
    ex.backtrace[0] =~ /^(.*?:\d+):/
    assert_equal from, $1
  end

  def assert_ruby_syntax_error(from, source, options = {})
    Slim::Template.new(options[:file], options) { source }.render(@env)
    raise 'Ruby syntax error expected'
  rescue SyntaxError => ex
    ex.message =~ /^(.*?:\d+):/
    assert_equal from, $1
  end
end

class Env
  def id_helper
    "notice"
  end

  def hash
    {:a => 'The letter a', :b => 'The letter b'}
  end

  def show_first?(show = false)
    show
  end

  def hello_world(text = "Hello World from @env", opts = {})
    text << opts.to_a * " " if opts.any?
    if block_given?
      "#{text} #{yield} #{text}"
    else
      text
    end
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
end
