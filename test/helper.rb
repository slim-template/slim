# encoding: utf-8

require 'minitest/unit'

MiniTest::Unit.autorun

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'slim'

class TestSlim < MiniTest::Unit::TestCase
  def setup
    @env = Env.new
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
    yield if block_given?
    text
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
