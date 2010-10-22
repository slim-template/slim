require 'helper'
require 'erb'

class TestSlimEmbeddedEngines < TestSlim
  def test_render_with_embedded_template
    source = %q{
p
  - text = 'before erb block'
  erb:
    <b>Hello from <%= text.upcase %>!</b>
    Second Line!
    <% if true %><%= true %><% end %>
}

    assert_html "<p><b>Hello from BEFORE ERB BLOCK!</b>\nSecond Line!\ntrue\n</p>", source
  end

  def test_render_with_interpolated_embedded_template
    source = %q{
markdown:
  #Header
  Hello from #{"Markdown!"}
  Second Line!
}
    assert_html "<h1>Header</h1>\n\n<p>Hello from Markdown!\nSecond Line!</p>\n", source
  end

  def test_render_with_javascript
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
    assert_html "<p><span>before liquid block</span>\n</p>", source
  end
end
