require 'helper'

class TestSlimCodeOutput < TestSlim
  def test_render_with_call
    string = <<HTML
p
  = hello_world
HTML

    expected = "<p>Hello World from @env</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_conditional_call
    string = <<HTML
p
  = hello_world if true
HTML

    expected = "<p>Hello World from @env</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_parameterized_call
    string = <<HTML
p
  = hello_world("Hello Ruby!")
HTML

    expected = "<p>Hello Ruby!</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_spaced_parameterized_call
    string = <<HTML
p
  = hello_world "Hello Ruby!"
HTML

    expected = "<p>Hello Ruby!</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_spaced_parameterized_call_2
    string = <<HTML
p
  = hello_world "Hello Ruby!", :dummy => "value"
HTML

    expected = "<p>Hello Ruby!dummy value</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_call_and_inline_text
    string = <<HTML
h1 This is my title
p
  = hello_world
HTML

    expected = "<h1>This is my title</h1><p>Hello World from @env</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_attribute_starts_with_keyword
    string = <<HTML
p = hello_world in_keyword
HTML

    expected = "<p>starts with keyword</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_hash_call
    string = <<HTML
p = hash[:a] 
HTML

    expected = "<p>The letter a</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end
end
