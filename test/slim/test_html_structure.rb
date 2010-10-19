require 'helper'

class TestSlimHtmlStructure < TestSlim
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

  def test_render_with_shortcut_attributes
    string = <<HTML
h1#title This is my title
#notice.hello.world
  = hello_world
HTML

    expected = "<h1 id=\"title\">This is my title</h1><div id=\"notice\" class=\"hello world\">Hello World from @env</div>"

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

    expected = "<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p><p>Some more markup</p>"

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

  def test_dashed_attributes
    string = <<HTML
p data-info="Illudium Q-36" = output_number
HTML

    expected = %(<p data-info="Illudium Q-36">1337</p>)

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_dashed_attributes_with_shortcuts
    string = <<HTML
p#marvin.martian data-info="Illudium Q-36" = output_number
HTML

    expected = %(<p id="marvin" class="martian" data-info="Illudium Q-36">1337</p>)

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_parens_around_attributes
    string = <<HTML
p(id="marvin" class="martian" data-info="Illudium Q-36") = output_number
HTML

    expected = %(<p id="marvin" class="martian" data-info="Illudium Q-36">1337</p>)

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_square_brackets_around_attributes
    string = <<HTML
p[id="marvin" class="martian" data-info="Illudium Q-36"] = output_number
HTML

    expected = %(<p id="marvin" class="martian" data-info="Illudium Q-36">1337</p>)

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_parens_around_attributes_with_equal_sign_snug_to_right_paren
    string = <<HTML
p(id="marvin" class="martian" data-info="Illudium Q-36")= output_number
HTML

    expected = %(<p id="marvin" class="martian" data-info="Illudium Q-36">1337</p>)

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end
end
