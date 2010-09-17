require 'helper'

class TestSlimEngine < MiniTest::Unit::TestCase

  def setup
    @env = Env.new
  end

  def test_simple_render
    string = <<HTML
html
  head
    title Simple Test Title
  body
    p Hello World, meet Slim.
HTML

    engine = Slim::Engine.new(string)

    expected = "<html><head><title>Simple Test Title</title></head><body><p>Hello World, meet Slim.</p></body></html>"

    assert_equal expected, engine.render
  end

  def test_render_with_conditional
    string = <<HTML
html
  head
    title Simple Test Title
  body
    - if show_first?
        p The first paragraph
    - else
        p The second paragraph
HTML

    engine = Slim::Engine.new(string)

    expected = "<html><head><title>Simple Test Title</title></head><body><p>The second paragraph</p></body></html>"

    assert_equal expected, engine.render(@env)
  end

  def test_render_with_call
    string = <<HTML
html
  head
    title Simple Test Title
  body
    p
      = hello_world
HTML

    engine = Slim::Engine.new(string)

    expected = "<html><head><title>Simple Test Title</title></head><body><p>Hello World from @env</p></body></html>"

    assert_equal expected, engine.render(@env)
  end

  def test_render_with_call_and_inline_text
    string = <<HTML
html
  head
    title Simple Test Title
  body
    h1 This is my title
    p
      = hello_world
HTML

    engine = Slim::Engine.new(string)

    expected = "<html><head><title>Simple Test Title</title></head><body><h1>This is my title</h1><p>Hello World from @env</p></body></html>"

    assert_equal expected, engine.render(@env)
  end

  def test_render_with_call_to_set_attribute
    string = <<HTML
html
  head
    title Simple Test Title
  body
    h1 This is my title
    p id="#\{id_helper}"
      = hello_world
HTML

    engine = Slim::Engine.new(string)

    expected = "<html><head><title>Simple Test Title</title></head><body><h1>This is my title</h1><p id=\"notice\">Hello World from @env</p></body></html>"

    assert_equal expected, engine.render(@env)
  end



end
