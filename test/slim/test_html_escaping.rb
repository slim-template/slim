require 'helper'

class TestSlimHtmlEscaping < TestSlim
  def test_html_will_not_be_escaped
    string = <<HTML
p <Hello> World, meet "Slim".
HTML

    expected = '<p><Hello> World, meet "Slim".</p>'

    assert_equal expected, Slim::Engine.new(string).render
  end

  def test_html_with_newline_will_not_be_escaped
    string = <<HTML
p
  |
    <Hello> World,
     meet "Slim".
HTML

    expected = '<p><Hello> World, meet "Slim".</p>'

    assert_equal expected, Slim::Engine.new(string).render
  end

  def test_html_with_escaped_interpolation
    string = <<HTML
- x = '"'
- content = '<x>'
p class="\#{x}" test \#{content}
HTML

    expected = '<p class="&quot;">test &lt;x&gt;</p>'

    assert_equal expected, Slim::Engine.new(string).render
  end
end
