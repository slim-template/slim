require 'helper'

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

    expected = <<-EOS
<div class="sect1">
<h2 id="_header">Header</h2>
<div class="sectionbody">
<div class="paragraph">
<p>Hello from AsciiDoc!</p>
</div>
<div class="paragraph">
<p>3</p>
</div>
<div class="ulist">
<ul>
<li>
<p>one</p>
</li>
<li>
<p>two</p>
</li>
</ul>
</div>
</div>
</div>
    EOS
    # render, then remove blank lines and unindent the remaining lines
    output = render(source).gsub(/^ *(\n|(?=[^ ]))/, '')

    assert_equal expected, output

    Slim::Embedded.with_options(:asciidoc => {:compact => true, :attributes => {'sectids!' => ''}}) do
      # render, then unindent lines
      output = render(source).gsub(/^ *(?=[^ ])/, '')
      assert_equal expected.gsub('<h2 id="_header">', '<h2>'), output
    end

    # render again, then remove blank lines and unindent the remaining lines
    output = render(source).gsub(/^ *(\n|(?=[^ ]))/, '')
    assert_equal expected, output
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
    assert_html "<h1 id=\"header\">Header</h1>\n<p>Hello from Markdown!</p>\n\n<p>3</p>\n\n<ul>\n  <li>one</li>\n  <li>two</li>\n</ul>\n", source

    Slim::EmbeddedEngine.with_options(:markdown => {:auto_ids => false}) do
      assert_html "<h1>Header</h1>\n<p>Hello from Markdown!</p>\n\n<p>3</p>\n\n<ul>\n  <li>one</li>\n  <li>two</li>\n</ul>\n", source
    end

    assert_html "<h1 id=\"header\">Header</h1>\n<p>Hello from Markdown!</p>\n\n<p>3</p>\n\n<ul>\n  <li>one</li>\n  <li>two</li>\n</ul>\n", source
  end

  def test_render_with_creole
    source = %q{
creole:
  = head1
  == head2
}
    assert_html "<h1>head1</h1><h2>head2</h2>", source
  end

  def test_render_with_builder
    source = %q{
builder:
  xml.p(:id => 'test') {
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
    assert_html %{<script type="text/javascript">$(function() {});\n\n\nalert('hello')</script><p>Hi</p>}, source
  end

  def test_render_with_javascript_with_tabs
    source = "javascript:\n\t$(function() {});\n\talert('hello')\np Hi"
    assert_html "<script type=\"text/javascript\">$(function() {});\nalert('hello')</script><p>Hi</p>", source
  end

  def test_render_with_javascript_including_variable
    # Keep the trailing space behind "javascript:   "!
    source = %q{
- func = "alert('hello');"
javascript:   
  $(function() { #{func} });
}
    assert_html %q|<script type="text/javascript">$(function() { alert('hello'); });</script>|, source
  end

  def test_render_with_javascript_with_explicit_html_comment
    Slim::Engine.with_options(:js_wrapper => :comment) do
      source = "javascript:\n\t$(function() {});\n\talert('hello')\np Hi"
      assert_html "<script type=\"text/javascript\"><!--\n$(function() {});\nalert('hello')\n//--></script><p>Hi</p>", source
    end
  end

  def test_render_with_javascript_with_explicit_cdata_comment
    Slim::Engine.with_options(:js_wrapper => :cdata) do
      source = "javascript:\n\t$(function() {});\n\talert('hello')\np Hi"
      assert_html "<script type=\"text/javascript\">\n//<![CDATA[\n$(function() {});\nalert('hello')\n//]]>\n</script><p>Hi</p>", source
    end
  end

  def test_render_with_javascript_with_format_xhtml_comment
    Slim::Engine.with_options(:js_wrapper => :guess, :format => :xhtml) do
      source = "javascript:\n\t$(function() {});\n\talert('hello')\np Hi"
      assert_html "<script type=\"text/javascript\">\n//<![CDATA[\n$(function() {});\nalert('hello')\n//]]>\n</script><p>Hi</p>", source
    end
  end

  def test_render_with_javascript_with_format_html_comment
    Slim::Engine.with_options(:js_wrapper => :guess, :format => :html) do
      source = "javascript:\n\t$(function() {});\n\talert('hello')\np Hi"
      assert_html "<script type=\"text/javascript\"><!--\n$(function() {});\nalert('hello')\n//--></script><p>Hi</p>", source
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
    assert_runtime_error 'Embedded engine ruby is disabled', source, :enable_engines => [:javascript]
    assert_runtime_error 'Embedded engine ruby is disabled', source, :enable_engines => %w(javascript)

    source = %{
ruby:
  Embedded Ruby
}
    assert_runtime_error 'Embedded engine ruby is disabled', source, :enable_engines => [:javascript]
    assert_runtime_error 'Embedded engine ruby is disabled', source, :enable_engines => %w(javascript)

    source = %{
ruby:
  Embedded Ruby
}
    assert_runtime_error 'Embedded engine ruby is disabled', source, :disable_engines => [:ruby]
    assert_runtime_error 'Embedded engine ruby is disabled', source, :disable_engines => %w(ruby)
  end

  def test_enabled_embedded_engine
    source = %q{
javascript:
  $(function() {});
}
    assert_html '<script type="text/javascript">$(function() {});</script>', source, :disable_engines => [:ruby]
    assert_html '<script type="text/javascript">$(function() {});</script>', source, :disable_engines => %w(ruby)

    source = %q{
javascript:
  $(function() {});
}
    assert_html '<script type="text/javascript">$(function() {});</script>', source, :enable_engines => [:javascript]
    assert_html '<script type="text/javascript">$(function() {});</script>', source, :enable_engines => %w(javascript)
  end
end
