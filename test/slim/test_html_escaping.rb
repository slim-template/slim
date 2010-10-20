require 'helper'

class TestSlimHtmlEscaping < TestSlim
  def test_render_with_content_and_quotes
    string = <<HTML
p Hello World, meet "Slim".
HTML

    expected = "<p>Hello World, meet \"Slim\".</p>"

    assert_equal expected, Slim::Engine.new(string).render
  end

  def test_render_with_newline_character
    string = <<HTML
p Hello World\\n, meet "Slim".
HTML

    expected = "<p>Hello World\\n, meet \"Slim\".</p>"

    assert_equal expected, Slim::Engine.new(string).render
  end
end
