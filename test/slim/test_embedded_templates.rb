require 'helper'
require 'erb'

class TestSlimEmbeddedTemplats < TestSlim
  def test_render_with_embedded_template
    source = %q{
p
  erb:
    <b>Hello from <%= 'erb'.upcase %>!</b>
}

    assert_html '<p><b>Hello from ERB!</b></p>', source
  end

  # Note that erb is a really bad example. You would usually use this with Markdown, CoffeeScript, Sass or akin.
  # It offers the same behavior as Haml.
  def test_render_with_interpolated_embedded_template
    source = %q{
erb:
  Hello from #{"ERB!"}
}
    assert_html 'Hello from ERB!', source
  end

end
