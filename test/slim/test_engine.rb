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

    expected = "<html><head><title>Simple Test Title</title></head><body><p>Hello World, meet Slim.</p></body></html>"

    assert_equal expected, Slim::Engine.new(string).render
  end

  def test_render_with_conditional
    string = <<HTML
div
  - if show_first?
      p The first paragraph
  - else
      p The second paragraph
HTML

    expected = "<div><p>The second paragraph</p></div>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_parameterized_conditional
    string = <<HTML
div
  - if show_first? false
      p The first paragraph
  - else
      p The second paragraph
HTML

    expected = "<div><p>The second paragraph</p></div>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_call
    string = <<HTML
p
  = hello_world
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

  def test_render_with_call_to_set_attributes
    string = <<HTML
p id="#\{id_helper}" class="hello world"
  = hello_world
HTML

    expected = "<p id=\"notice\" class=\"hello world\">Hello World from @env</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_shortcut_attributes
    string = <<HTML
h1#title This is my title
#notice.hello.world
  = hello_world
HTML

    expected = "<h1 id=\"title\">This is my title</h1><div id=\"notice\" class=\"hello world\">Hello World from @env</div>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_call_to_set_attributes_and_call_to_set_content
    string = <<HTML
p id="#\{id_helper}" class="hello world" = hello_world
HTML

    expected = "<p id=\"notice\" class=\"hello world\">Hello World from @env</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_parameterized_call_to_set_attributes_and_call_to_set_content
    string = <<HTML
p id="#\{id_helper}" class="hello world" = hello_world("Hello Ruby!")
HTML

    expected = "<p id=\"notice\" class=\"hello world\">Hello Ruby!</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_spaced_parameterized_call_to_set_attributes_and_call_to_set_content
    string = <<HTML
p id="#\{id_helper}" class="hello world" = hello_world "Hello Ruby!"
HTML

    expected = "<p id=\"notice\" class=\"hello world\">Hello Ruby!</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_spaced_parameterized_call_to_set_attributes_and_call_to_set_content_2
    string = <<HTML
p id="#\{id_helper}" class="hello world" = hello_world "Hello Ruby!", :dummy => "value"
HTML

    expected = "<p id=\"notice\" class=\"hello world\">Hello Ruby!dummy value</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_text_block
    string = <<HTML
p
  `
   Lorem ipsum dolor sit amet, consectetur adipiscing elit.
HTML

    expected = "<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_text_block_with_subsequent_markup
    string = <<HTML
p
  `
    Lorem ipsum dolor sit amet, consectetur adipiscing elit.
p Some more markup
HTML

    expected = "<p> Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p><p>Some more markup</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_output_code_block
    string = <<HTML
p
  = hello_world "Hello Ruby!" do
    | Hello from within a block!
HTML

    expected = "<p>Hello from within a block!Hello Ruby!</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_output_code_within_block
    string = <<HTML
p
  = hello_world "Hello Ruby!" do
    = hello_world "Hello from within a block! "
HTML

    expected = "<p>Hello from within a block! Hello Ruby!</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_control_code_loop
    string = <<HTML
p
  - 3.times do
    | Hey!
HTML

    expected = "<p>Hey!Hey!Hey!</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end
end
