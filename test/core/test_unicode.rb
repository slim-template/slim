# -*- coding: utf-8 -*-
if ''.respond_to?(:encoding)
  require 'helper'

  class TestSlimUnicode < TestSlim
    def test_unicode_tags
      source = "cтатья года"
      result = "<cтатья>года</cтатья>"
      assert_html result, source
    end

    def test_unicode_attrs
      source = "cтатья года=123 content"
      result = "<cтатья года=\"123\">content</cтатья>"
      assert_html result, source
    end
  end
end
