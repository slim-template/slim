require 'helper'

class TestSlimEncoding < TestSlim
  def test_binary
    source = "| \xFF\xFF"
    result = "\xFF\xFF"
    assert_html result, source
  end
end
