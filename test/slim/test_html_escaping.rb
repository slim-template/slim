require 'helper'

class TestSlimHtmlEscaping < TestSlim
  def test_html_will_not_be_escaped
    source = %q{
p <Hello> World, meet "Slim".
}

    assert_html '<p><Hello> World, meet "Slim".</p>', source
  end

  def test_html_with_newline_will_not_be_escaped
    source = %q{
p
  |
    <Hello> World,
     meet "Slim".
}

    assert_html "<p><Hello> World,\n meet \"Slim\".</p>", source
  end

  def test_html_with_escaped_interpolation
    source = %q{
- x = '"'
- content = '<x>'
p class="#{x}" test #{content}
}

    assert_html '<p class="&quot;">test &lt;x&gt;</p>', source
  end

  def test_html_nested_escaping
    source = %q{
= hello_world do
  | escaped &
}
    assert_html 'Hello World from @env escaped &amp; Hello World from @env', source
  end
end
