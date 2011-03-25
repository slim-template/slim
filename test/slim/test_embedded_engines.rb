require 'helper'
begin
  require('creole/template')
rescue LoadError
end

class TestSlimEmbeddedEngines < TestSlim
  def test_render_with_haml
    source = %q{
p
  - text = 'haml'
  haml:
    %b Hello from #{text.upcase}!
    Second Line!
    - if true
      = true
}

    assert_html "<p><b>Hello from HAML!</b>\nSecond Line!\ntrue\n</p>", source
  end

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
  "Second Line!"
}
    assert_html "<h1>Header</h1>\n\n<p>Hello from Markdown!\n\"Second Line!\"</p>\n", source
  end

  def test_render_with_creole
    source = %q{
creole:
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
}
    assert_html '<script type="text/javascript">$(function() {});</script>', source
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

  def test_render_with_liquid
    source = %q{
p
  - text = 'before liquid block'
  liquid:
    <span>{{text}}</span>
}
    assert_html "<p><span>before liquid block</span></p>", source
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
    assert_runtime_error 'Embedded engine ruby is disabled', source, :enable_engines => %w(javascript)

    source = %{
ruby:
  Embedded Ruby
}
    assert_runtime_error 'Embedded engine ruby is disabled', source, :enable_engines => %w(javascript)

    source = %{
ruby:
  Embedded Ruby
}
    assert_runtime_error 'Embedded engine ruby is disabled', source, :disable_engines => %w(ruby)
  end

  def test_enabled_embedded_engine
    source = %q{
javascript:
  $(function() {});
}
    assert_html '<script type="text/javascript">$(function() {});</script>', source, :disable_engines => %w(ruby)

    source = %q{
javascript:
  $(function() {});
}
    assert_html '<script type="text/javascript">$(function() {});</script>', source, :enable_engines => %w(javascript)
  end
end
