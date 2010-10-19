require 'helper'

class TestSlimCodeEscaping < TestSlim
  def test_escaping_evil_method
    string = <<HTML
p = evil_method
HTML

    expected = "<p>&lt;script&gt;do_something_evil();&lt;&#47;script&gt;</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_escape_interpolation
    string = <<HTML
p \\\#{hello_world}
HTML

    expected = "<p>\#{hello_world}</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end
end
