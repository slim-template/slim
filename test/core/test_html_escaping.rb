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

  def test_html_quoted_attr_escape
    source = %q{
p id="&" class=="&amp;"
}

    assert_html '<p class="&amp;" id="&amp;"></p>', source
  end

  def test_html_quoted_attr_escape_with_interpolation
    source = %q{
p id="&#{'"'}" class=="&amp;#{'"'}"
p id="&#{{'"'}}" class=="&amp;#{{'"'}}"
}

    assert_html '<p class="&amp;&quot;" id="&amp;&quot;"></p><p class="&amp;"" id="&amp;""></p>', source
  end

  def test_html_ruby_attr_escape
    source = %q{
p id=('&'.to_s) class==('&amp;'.to_s)
}

    assert_html '<p class="&amp;" id="&amp;"></p>', source
  end
end
