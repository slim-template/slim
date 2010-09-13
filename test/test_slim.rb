require 'helper'

class TestSlim < MiniTest::Unit::TestCase
  def test_version_is_current
    assert_equal '0.0.1', Slim.version
  end
end
