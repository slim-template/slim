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
    String.send(:remove_method, :html_safe?) if String.method_defined?(:html_safe?)
    Slim::Filter::DEFAULT_OPTIONS.delete(:use_html_safe)
  end

  def assert_html(expected, source, options = {})
    assert_equal expected, Slim::Engine.new(source, options).render(@env)
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
