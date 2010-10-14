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

  def test_render_with_consecutive_conditionals
    string = <<HTML
div
  - if show_first? true
      p The first paragraph
  - if show_first? true
      p The second paragraph
HTML

    expected = "<div><p>The first paragraph</p><p>The second paragraph</p></div>"

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

  def test_render_with_call_to_set_attributes
    string = <<HTML
p id="#\{id_helper}" class="hello world"
  = hello_world
HTML

    expected = "<p id=\"notice\" class=\"hello world\">Hello World from @env</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_call_to_set_custom_attributes
    string = <<HTML
p data-id="#\{id_helper}" data-class="hello world"
  = hello_world
HTML

    expected = "<p data-id=\"notice\" data-class=\"hello world\">Hello World from @env</p>"

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

  def test_render_with_inline_condition
    string = <<HTML
p = hello_world if true
HTML

    expected = "<p>Hello World from @env</p>"

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

  def test_escaping_evil_method
    string = <<HTML
p = evil_method
HTML

    expected = "<p>&lt;script&gt;do_something_evil();&lt;&#47;script&gt;</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end


  def test_nested_text
    string = <<HTML
p 
 |
  This is line one.
   This is line two.
    This is line three.
     This is line four.
p This is a new paragraph.
HTML

    expected = "<p>This is line one. This is line two.  This is line three.   This is line four.</p><p>This is a new paragraph.</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_nested_text_with_nested_html
    string = <<HTML
p
 |
  This is line one.
   This is line two.
    This is line three.
     This is line four.
 span.bold This is a bold line in the paragraph.
 |  This is more content.
HTML

    expected = "<p>This is line one. This is line two.  This is line three.   This is line four.<span class=\"bold\">This is a bold line in the paragraph.</span> This is more content.</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)

  end


  def test_simple_paragraph_with_padding
    string = <<HTML
p    There will be 3 spaces in front of this line.
HTML

    expected = "<p>   There will be 3 spaces in front of this line.</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_output_code_with_leading_spaces
    string = <<HTML
p= hello_world
p = hello_world
p    = hello_world
HTML

    expected = "<p>Hello World from @env</p><p>Hello World from @env</p><p>Hello World from @env</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_interpolation_in_text
    string = <<HTML
p 
 | \#{hello_world}
p 
 | 
  A message from the compiler: \#{hello_world}
HTML

    expected = "<p>Hello World from @env</p><p>A message from the compiler: Hello World from @env</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_interpolation_in_tag
    string = <<HTML
p \#{hello_world}
HTML

    expected = "<p>Hello World from @env</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_escape_interpolation
    string = <<HTML
p \\\#{hello_world}
HTML

    expected = "<p>\#{hello_world}</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end
end
