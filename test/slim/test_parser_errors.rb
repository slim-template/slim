require 'helper'

class TestParserErrors < TestSlim
  def test_correct_filename
    source = %q{
doctype 5
  div Invalid
}

    assert_syntax_error "Unexpected indentation\n  test.slim, Line 3\n    div Invalid\n    ^\n", source, :file => 'test.slim'
  end

  def test_unexpected_indentation
    source = %q{
doctype 5
  div Invalid
}

    assert_syntax_error "Unexpected indentation\n  (__TEMPLATE__), Line 3\n    div Invalid\n    ^\n", source
  end

  def test_unexpected_text_indentation
    source = %q{
p
  | text block
   text
}

    assert_syntax_error "Unexpected text indentation\n  (__TEMPLATE__), Line 4\n    text\n    ^\n", source
  end

  def test_malformed_indentation
    source = %q{
p
  div Valid
 div Invalid
}

    assert_syntax_error "Malformed indentation\n  (__TEMPLATE__), Line 4\n    div Invalid\n    ^\n", source
  end

  def test_unknown_line_indicator
    source = %q{
p
  div Valid
  .valid
  #valid
  ?invalid
}

    assert_syntax_error "Unknown line indicator\n  (__TEMPLATE__), Line 6\n    ?invalid\n    ^\n", source
  end

  def test_expected_closing_delimiter
    source = %q{
p
  img(src="img.jpg" title={title}
}

    assert_syntax_error "Expected closing delimiter )\n  (__TEMPLATE__), Line 3\n    img(src=\"img.jpg\" title={title}\n                                   ^\n", source
  end

  def test_expected_closing_attribute_delimiter
    source = %q{
p
  img src=[hash[1] + hash[2]
}

    assert_syntax_error "Expected closing attribute delimiter ]\n  (__TEMPLATE__), Line 3\n    img src=[hash[1] + hash[2]\n                              ^\n", source
  end

  def test_expected_attribute
    source = %q{
p
  img(src='img.png' whatsthis?!)
}

    assert_syntax_error "Expected attribute\n  (__TEMPLATE__), Line 3\n    img(src='img.png' whatsthis?!)\n                      ^\n", source
  end

  def test_invalid_empty_attribute
    source = %q{
p
  img{src= }
}

    assert_syntax_error "Invalid empty attribute\n  (__TEMPLATE__), Line 3\n    img{src= }\n            ^\n", source
  end

  def test_invalid_empty_attribute2
    source = %q{
p
  img{src=}
}

    assert_syntax_error "Invalid empty attribute\n  (__TEMPLATE__), Line 3\n    img{src=}\n            ^\n", source
  end

  def test_invalid_empty_attribute3
    source = %q{
p
  img src=
}

    assert_syntax_error "Invalid empty attribute\n  (__TEMPLATE__), Line 3\n    img src=\n            ^\n", source
  end
end
