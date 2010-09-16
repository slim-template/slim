require 'helper'

class TestSlim < MiniTest::Unit::TestCase
  def test_version_is_current
    assert_equal '0.1.0', Slim.version
  end
end
