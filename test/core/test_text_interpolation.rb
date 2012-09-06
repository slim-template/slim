require 'helper'

class TestSlimTextInterpolation < TestSlim
  def test_interpolation_in_attribute
    source = %q{
p id="a#{id_helper}b" = hello_world
}

    assert_html '<p id="anoticeb">Hello World from @env</p>', source
  end

  def test_nested_interpolation_in_attribute
    source = %q{
p id="#{"abc#{1+1}" + "("}" = hello_world
}

    assert_html '<p id="abc2(">Hello World from @env</p>', source
  end

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
p text1 \\#{hello_world} text2
}

    assert_html '<p>#{hello_world}</p><p>text1 #{hello_world} text2</p>', source
  end

  def test_complex_interpolation
    source = %q{
p Message: #{message('hello', "user #{output_number}")}
}

    assert_html '<p>Message: hello user 1337</p>', source
  end

  def test_interpolation_with_escaping
    source = %q{
| #{evil_method}
}

    assert_html '&lt;script&gt;do_something_evil();&lt;/script&gt;', source
  end

  def test_interpolation_without_escaping
    source = %q{
| #{{evil_method}}
}

    assert_html '<script>do_something_evil();</script>', source
  end

  def test_interpolation_with_escaping_and_delimiter
    source = %q{
| #{(evil_method)}
}
    assert_html '&lt;script&gt;do_something_evil();&lt;/script&gt;', source
  end
end
