require 'helper'

class TestSlimEncoding < TestSlim
  def test_windows_crlf
    source = "a href='#' something\r\nbr\r\na href='#' others\r\n"
    result = "<a href=\"#\">something</a><br /><a href=\"#\">others</a>"
    assert_html result, source
  end

  def test_binary
    source = "| \xFF\xFF"
    result = "\xFF\xFF"
    assert_html result, source
  end

  def test_bom
    source = "\xEF\xBB\xBFh1 Hello World!"
    result = '<h1>Hello World!</h1>'
    assert_html result, source
  end
end
