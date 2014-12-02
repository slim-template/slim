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

  def test_render_without_html_safe2
    source = %q{
p = "<strong>Hello World\\n, meet 'Slim'</strong>."
}

    assert_html "<p>&lt;strong&gt;Hello World\n, meet &#39;Slim&#39;&lt;/strong&gt;.</p>", source
  end

  def test_render_with_html_safe_false
    source = %q{
p = "<strong>Hello World\\n, meet \\"Slim\\"</strong>."
}

    with_html_safe do
      assert_html "<p>&lt;strong&gt;Hello World\n, meet \&quot;Slim\&quot;&lt;/strong&gt;.</p>", source, use_html_safe: true
    end
  end

  def test_render_with_html_safe_true
    source = %q{
p = "<strong>Hello World\\n, meet \\"Slim\\"</strong>.".html_safe
}

    with_html_safe do
      assert_html "<p><strong>Hello World\n, meet \"Slim\"</strong>.</p>", source, use_html_safe: true
    end
  end

  def test_render_splat_with_html_safe_true
    source = %q{
p *{ title: '&amp;'.html_safe }
}

    with_html_safe do
      assert_html "<p title=\"&amp;\"></p>", source, use_html_safe: true
    end
  end

  def test_render_splat_with_html_safe_false
    source = %q{
p *{ title: '&' }
}

    with_html_safe do
      assert_html "<p title=\"&amp;\"></p>", source, use_html_safe: true
    end
  end


  def test_render_attribute_with_html_safe_true
    source = %q{
p title=('&amp;'.html_safe)
}

    with_html_safe do
      assert_html "<p title=\"&amp;\"></p>", source, use_html_safe: true
    end
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

    assert_html "<p>Hello</p><p>World</p>", source, disable_escape: true
  end

  def test_escaping_evil_method_with_pretty
    source = %q{
p = evil_method
}

    assert_html "<p>\n  &lt;script&gt;do_something_evil();&lt;/script&gt;\n</p>", source, pretty: true
  end

  def test_render_without_html_safe_with_pretty
    source = %q{
p = "<strong>Hello World\\n, meet \\"Slim\\"</strong>."
}

    assert_html "<p>\n  &lt;strong&gt;Hello World\n  , meet \&quot;Slim\&quot;&lt;/strong&gt;.\n</p>", source, pretty: true
  end

  def test_render_with_html_safe_false_with_pretty
    source = %q{
p = "<strong>Hello World\\n, meet \\"Slim\\"</strong>."
}

    with_html_safe do
      assert_html "<p>\n  &lt;strong&gt;Hello World\n  , meet \&quot;Slim\&quot;&lt;/strong&gt;.\n</p>", source, use_html_safe: true, pretty: true
    end
  end

  def test_render_with_html_safe_true_with_pretty
    source = %q{
p = "<strong>Hello World\\n, meet \\"Slim\\"</strong>.".html_safe
}

    with_html_safe do
      assert_html "<p>\n  <strong>Hello World\n  , meet \"Slim\"</strong>.\n</p>", source, use_html_safe: true, pretty: true
    end
  end

  def test_render_with_disable_escape_false_with_pretty
    source = %q{
= "<p>Hello</p>"
== "<p>World</p>"
}

    assert_html "&lt;p&gt;Hello&lt;/p&gt;<p>World</p>", source, pretty: true
  end

  def test_render_with_disable_escape_true_with_pretty
    source = %q{
= "<p>Hello</p>"
== "<p>World</p>"
}

    assert_html "<p>Hello</p><p>World</p>", source, disable_escape: true, pretty: true
  end
end
