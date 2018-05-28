require 'helper'
require 'erb'

class TestSlimEmbeddedEngines < TestSlim

  def test_render_with_markdown
    source = %q{
markdown:
  #Header
  Hello from #{"Markdown!"}

  #{1+2}

  * one
  * two
}
    if ::Tilt['md'].name =~ /Redcarpet/
      # redcarpet
      assert_html "<h1>Header</h1>\n\n<p>Hello from Markdown!</p>\n\n<p>3</p>\n\n<ul>\n<li>one</li>\n<li>two</li>\n</ul>\n", source
    elsif ::Tilt['md'].name =~ /RDiscount/
      # rdiscount
      assert_html "<h1>Header</h1>\n\n<p>Hello from Markdown!</p>\n\n<p>3</p>\n\n<ul>\n<li>one</li>\n<li>two</li>\n</ul>\n\n", source
    else
      # kramdown, :auto_ids by default
      assert_html "<h1 id=\"header\">Header</h1>\n<p>Hello from Markdown!</p>\n\n<p>3</p>\n\n<ul>\n  <li>one</li>\n  <li>two</li>\n</ul>\n", source

      Slim::Embedded.with_options(markdown: {auto_ids: false}) do
        assert_html "<h1>Header</h1>\n<p>Hello from Markdown!</p>\n\n<p>3</p>\n\n<ul>\n  <li>one</li>\n  <li>two</li>\n</ul>\n", source
      end

      assert_html "<h1 id=\"header\">Header</h1>\n<p>Hello from Markdown!</p>\n\n<p>3</p>\n\n<ul>\n  <li>one</li>\n  <li>two</li>\n</ul>\n", source
    end
  end

  def test_render_with_javascript
    source = %q{
javascript:
  $(function() {});


  alert('hello')
p Hi
}
    assert_html %{<script>$(function() {});\n\n\nalert('hello')</script><p>Hi</p>}, source
  end

  def test_render_with_opal
    begin
      require 'opal'
    rescue LoadError
      return
    end

    source = %q{
opal:
  puts 'hello from opal'
}
    assert_match '$puts("hello from opal")', render(source)
  end

  def test_render_with_javascript_with_tabs
    source = "javascript:\n\t$(function() {});\n\talert('hello')\np Hi"
    assert_html "<script>$(function() {});\nalert('hello')</script><p>Hi</p>", source
  end

  def test_render_with_javascript_including_variable
    source = %q{
- func = "alert('hello');"
javascript:
  $(function() { #{func} });
}
    assert_html %q|<script>$(function() { alert(&#39;hello&#39;); });</script>|, source
  end

  def test_render_with_javascript_with_explicit_html_comment
    Slim::Engine.with_options(js_wrapper: :comment) do
      source = "javascript:\n\t$(function() {});\n\talert('hello')\np Hi"
      assert_html "<script><!--\n$(function() {});\nalert('hello')\n//--></script><p>Hi</p>", source
    end
  end

  def test_render_with_javascript_with_explicit_cdata_comment
    Slim::Engine.with_options(js_wrapper: :cdata) do
      source = "javascript:\n\t$(function() {});\n\talert('hello')\np Hi"
      assert_html "<script>\n//<![CDATA[\n$(function() {});\nalert('hello')\n//]]>\n</script><p>Hi</p>", source
    end
  end

  def test_render_with_javascript_with_format_xhtml_comment
    Slim::Engine.with_options(js_wrapper: :guess, format: :xhtml) do
      source = "javascript:\n\t$(function() {});\n\talert('hello')\np Hi"
      assert_html "<script>\n//<![CDATA[\n$(function() {});\nalert('hello')\n//]]>\n</script><p>Hi</p>", source
    end
  end

  def test_render_with_javascript_with_format_html_comment
    Slim::Engine.with_options(js_wrapper: :guess, format: :html) do
      source = "javascript:\n\t$(function() {});\n\talert('hello')\np Hi"
      assert_html "<script><!--\n$(function() {});\nalert('hello')\n//--></script><p>Hi</p>", source
    end
  end

  def test_render_with_ruby
    source = %q{
ruby:
  variable = 1 +
  2
= variable
}
    assert_html '3', source
  end

  def test_render_with_ruby_heredoc
    source = %q{
ruby:
  variable = <<-MSG
  foobar
  MSG
= variable
}
    assert_html "foobar\n", source
  end

  def test_render_with_scss
    source = %q{
scss:
  $color: #f00;
  body { color: $color; }
}
    assert_html "<style type=\"text/css\">body{color:red}</style>", source
  end

  def test_disabled_embedded_engine
    source = %{
ruby:
  Embedded Ruby
}
    assert_runtime_error 'Embedded engine ruby is disabled', source, enable_engines: [:javascript]
    assert_runtime_error 'Embedded engine ruby is disabled', source, enable_engines: %w(javascript)

    source = %{
ruby:
  Embedded Ruby
}
    assert_runtime_error 'Embedded engine ruby is disabled', source, enable_engines: [:javascript]
    assert_runtime_error 'Embedded engine ruby is disabled', source, enable_engines: %w(javascript)

    source = %{
ruby:
  Embedded Ruby
}
    assert_runtime_error 'Embedded engine ruby is disabled', source, disable_engines: [:ruby]
    assert_runtime_error 'Embedded engine ruby is disabled', source, disable_engines: %w(ruby)
  end

  def test_enabled_embedded_engine
    source = %q{
javascript:
  $(function() {});
}
    assert_html '<script>$(function() {});</script>', source, disable_engines: [:ruby]
    assert_html '<script>$(function() {});</script>', source, disable_engines: %w(ruby)

    source = %q{
javascript:
  $(function() {});
}
    assert_html '<script>$(function() {});</script>', source, enable_engines: [:javascript]
    assert_html '<script>$(function() {});</script>', source, enable_engines: %w(javascript)
  end
end
