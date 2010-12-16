require 'helper'

class TestSlimValidator < TestSlim
  def test_valid_true?
    source = %q{
p Slim
}
    assert_valid? true, source
  end

  def test_valid_false?
    source = %q{
 p
  Slim
}
    assert_valid? false, source
  end

  def test_valid!
    source = %q{
p Slim
}
    assert_valid! false, source
  end

  def test_invalid!
    source = %q{
 p
  Slim
}
    assert_invalid! Slim::Parser::SyntaxError, source
  end

  private

  def assert_valid?(expected, source)
    assert_equal expected, Slim::Validator.valid?(source)
  end

  def assert_valid!(expected, source)
    assert_equal true, Slim::Validator.validate!(source)
  end

  def assert_invalid!(expected, source)
    assert_equal expected, Slim::Validator.validate!(source).class
  end
end
