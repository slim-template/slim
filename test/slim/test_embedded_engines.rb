require 'helper'
require 'erb'

class TestSlimEmbeddedEngines < TestSlim
  def test_render_with_embedded_template
    source = %q{
p
  erb:
    <b>Hello from <%= 'erb'.upcase %>!</b>
    Second Line!
}

    assert_html "<p><b>Hello from ERB!</b>\nSecond Line!\n</p>", source
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
end
