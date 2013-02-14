# -*- coding: utf-8 -*-
if ''.respond_to?(:encoding)
  require 'helper'

  class TestSlimUnicode < TestSlim
    def test_unicode_tags
      source = "статья года"
      result = "<статья>года</статья>"
      assert_html result, source
    end

    def test_unicode_attrs
      source = "статья года=123 content"
      result = "<статья года=\"123\">content</статья>"
      assert_html result, source
    end
  end
end
