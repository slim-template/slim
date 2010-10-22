require 'helper'
require 'erb'

class TestSlimEmbeddedTemplats < TestSlim
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
  Hello from #{"Markdown!"}
  Second Line!
}
    assert_html "<p>Hello from Markdown!\nSecond Line!</p>\n", source
  end

  def test_render_with_javascript
    source = %q{
javascript:   
  $(function() {});
}
    assert_html '<script type="text/javascript">$(function() {});</script>', source
  end

end
