require 'helper'

class TestSlimUnicode < TestSlim
  def test_unicode_tags
    source = "Статья года"
    result = "<Статья>года</Статья>"
    assert_html result, source
  end

  def test_unicode_attrs
    source = "Статья года=123 content"
    result = "<Статья года=\"123\">content</Статья>"
    assert_html result, source
  end
end
