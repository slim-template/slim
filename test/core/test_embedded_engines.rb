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
