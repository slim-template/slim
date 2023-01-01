require 'helper'
require 'erb'

class TestSlimEmbeddedEngines < TestSlim

  def test_render_with_markdown
    source = %q{
markdown:
  #Header
  Hello from #{"Markdown!"}

  #{1+2}

  [#{1}](#{"#2"})

  * one
  * two
}
    if ::Tilt['md'].name =~ /Redcarpet/
      # redcarpet
      assert_html "<h1>Header</h1>\n\n<p>Hello from Markdown!</p>\n\n<p>3</p>\n\n<p><a href=\"#2\">1</a></p>\n\n<ul>\n<li>one</li>\n<li>two</li>\n</ul>\n", source
    elsif ::Tilt['md'].name =~ /RDiscount/
      # rdiscount
      assert_html "<h1>Header</h1>\n\n<p>Hello from Markdown!</p>\n\n<p>3</p>\n\n<p><a href=\"#2\">1</a></p>\n\n<ul>\n<li>one</li>\n<li>two</li>\n</ul>\n\n", source
    else
      # kramdown, :auto_ids by default
      assert_html "<h1 id=\"header\">Header</h1>\n<p>Hello from Markdown!</p>\n\n<p>3</p>\n\n<p><a href=\"#2\">1</a></p>\n\n<ul>\n  <li>one</li>\n  <li>two</li>\n</ul>\n", source

      Slim::Embedded.with_options(markdown: {auto_ids: false}) do
        assert_html "<h1>Header</h1>\n<p>Hello from Markdown!</p>\n\n<p>3</p>\n\n<p><a href=\"#2\">1</a></p>\n\n<ul>\n  <li>one</li>\n  <li>two</li>\n</ul>\n", source
      end

      assert_html "<h1 id=\"header\">Header</h1>\n<p>Hello from Markdown!</p>\n\n<p>3</p>\n\n<p><a href=\"#2\">1</a></p>\n\n<ul>\n  <li>one</li>\n  <li>two</li>\n</ul>\n", source
    end
  end

  def test_render_with_css
    source = %q{
css:
  h1 { color: blue }
}
  assert_html "<style>h1 { color: blue }</style>", source
  end

  def test_render_with_css_empty_attributes
    source = %q{
css []:
  h1 { color: blue }
}
  assert_html "<style>h1 { color: blue }</style>", source
  end

  def test_render_with_css_attribute
    source = %q{
css scoped = "true":
  h1 { color: blue }
}
  assert_html "<style scoped=\"true\">h1 { color: blue }</style>", source
  end

  def test_render_with_css_multiple_attributes
    source = %q{
css class="myClass" scoped = "true" :
  h1 { color: blue }
}
  assert_html "<style class=\"myClass\" scoped=\"true\">h1 { color: blue }</style>", source
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

  def test_render_with_javascript_empty_attributes
    source = %q{
javascript ():
  alert('hello')
}
    assert_html %{<script>alert('hello')</script>}, source
  end

  def test_render_with_javascript_attribute
    source = %q{
javascript [class = "myClass"]:
  alert('hello')
}
    assert_html %{<script class=\"myClass\">alert('hello')</script>}, source
  end

  def test_render_with_javascript_multiple_attributes
    source = %q{
javascript { class = "myClass" id="myId" other-attribute = 'my_other_attribute' }  :
  alert('hello')
}
    assert_html %{<script class=\"myClass\" id=\"myId\" other-attribute=\"my_other_attribute\">alert('hello')</script>}, source
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

# TODO: Reactivate sass tests
if false
  def test_render_with_scss
    source = %q{
scss:
  $color: #f00;
  body { color: $color; }
}
    assert_html "<style>body{color:red}</style>", source
  end

  def test_render_with_scss_attribute
    source = %q{
scss [class="myClass"]:
  $color: #f00;
  body { color: $color; }
}
    assert_html "<style class=\"myClass\">body{color:red}</style>", source
  end

  def test_render_with_sass
    source = %q{
sass:
  $color: #f00
  body
    color: $color
}
    assert_html "<style>body{color:red}</style>", source
  end

  def test_render_with_sass_attribute
    source = %q{
sass [class="myClass"]:
  $color: #f00
  body
    color: $color
}
    assert_html "<style class=\"myClass\">body{color:red}</style>", source
  end
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
