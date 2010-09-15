# encoding: utf-8

require 'minitest/unit'

MiniTest::Unit.autorun

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'slim'


class Env
  def show_first?
    false
  end

  def hello_world
    "Hello World from @env"
  end
end
