require 'helper'

class TestSlimCodeEscaping < TestSlim
  def test_escaping_evil_method
    source = %q{
p = evil_method
}

    assert_html '<p>&lt;script&gt;do_something_evil();&lt;/script&gt;</p>', source
  end

  def test_render_without_html_safe
    source = %q{
p = "<strong>Hello World\\n, meet \\"Slim\\"</strong>."
}

    assert_html "<p>&lt;strong&gt;Hello World\n, meet \&quot;Slim\&quot;&lt;/strong&gt;.</p>", source
  end

  def test_render_with_html_safe_false
    source = %q{
p = HtmlUnsafeString.new("<strong>Hello World\\n, meet \\"Slim\\"</strong>.")
}

    assert_html "<p>&lt;strong&gt;Hello World\n, meet \&quot;Slim\&quot;&lt;/strong&gt;.</p>", source, :use_html_safe => true
  end

  def test_render_with_html_safe_true
    source = %q{
p = HtmlSafeString.new("<strong>Hello World\\n, meet \\"Slim\\"</strong>.")
}

    assert_html "<p><strong>Hello World\n, meet \"Slim\"</strong>.</p>", source, :use_html_safe => true
  end

  def test_render_with_disable_escape_false
    source = %q{
= "<p>Hello</p>"
== "<p>World</p>"
}

    assert_html "&lt;p&gt;Hello&lt;/p&gt;<p>World</p>", source
  end

  def test_render_with_disable_escape_true
    source = %q{
= "<p>Hello</p>"
== "<p>World</p>"
}

    assert_html "<p>Hello</p><p>World</p>", source, :disable_escape => true
  end
end
