require 'helper'
require 'erb' #asciidoctor fail to load it randomly

class TestSlimEmbeddedEngines < TestSlim
  def test_render_with_erb
    source = %q{
p
  - text = 'before erb block'
  erb:
    <b>Hello from <%= text.upcase %>!</b>
    Second Line!
    <% if true %><%= true %><% end %>
}

    assert_html "<p><b>Hello from BEFORE ERB BLOCK!</b>\nSecond Line!\ntrue</p>", source
  end

  def test_wip_render_with_asciidoc
    source = %q{
asciidoc:
  == Header
  Hello from #{"AsciiDoc!"}

  #{1+2}

  * one
  * two
}
    output = render(source)
    assert_match 'sect1', output
    assert_match 'Hello from AsciiDoc!', output
  end

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

  def test_render_with_creole
    source = %q{
creole:
  = head1
  == head2
}
    assert_html "<h1>head1</h1><h2>head2</h2>", source
  end

  def test_render_with_creole_one_line
    source = %q{
creole: Hello **world**,
  we can write one-line embedded markup now!
  = Headline
  Text
.nested: creole: **Strong**
}
    assert_html '<p>Hello <strong>world</strong>, we can write one-line embedded markup now!</p><h1>Headline</h1><p>Text</p><div class="nested"><p><strong>Strong</strong></p></div>', source
  end

  def test_render_with_org
    # HACK: org-ruby registers itself in Tilt
    require 'org-ruby'

    source = %q{
org:
  * point1
  * point2
}
    assert_html "<h1>point1</h1>\n<h1>point2</h1>\n", source
  end

  def test_render_with_builder
    source = %q{
builder:
  xml.p(id: 'test') {
    xml.text!('Hello')
  }
}
    assert_html "<p id=\"test\">\nHello</p>\n", source
  end

  def test_render_with_wiki
    source = %q{
wiki:
  = head1
  == head2
}
    assert_html "<h1>head1</h1><h2>head2</h2>", source
  end

  def test_render_with_javascript
    # Keep the trailing space behind "javascript:   "!
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
      # HACK: org-ruby registers itself in Tilt
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
    # Keep the trailing space behind "javascript:   "!
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
