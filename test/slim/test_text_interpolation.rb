require 'helper'

class TestSlimTextInterpolation < TestSlim

  def test_interpolation_in_text
    source = %q{
p
 | #{hello_world} with "quotes"
p
 |
  A message from the compiler: #{hello_world}
}

    assert_html '<p>Hello World from @env with "quotes"</p><p>A message from the compiler: Hello World from @env</p>', source
  end

  def test_interpolation_in_tag
    source = %q{
p #{hello_world}
}

    assert_html '<p>Hello World from @env</p>', source
  end

  def test_escape_interpolation
    source = %q{
p \\#{hello_world}
}

    assert_html '<p>#{hello_world}</p>', source
  end

  def test_complex_interpolation
    source = %q{
p Message: #{message('hello', "user #{output_number}")}
}

    assert_html '<p>Message: hello user 1337</p>', source
  end
end
