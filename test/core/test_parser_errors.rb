require 'helper'

class TestParserErrors < TestSlim
  def test_correct_filename
    source = %q{
doctype 5
  div Invalid
}

    assert_syntax_error "Unexpected indentation\n  test.slim, Line 3, Column 2\n    div Invalid\n    ^\n", source, file: 'test.slim'
  end

  def test_unexpected_indentation
    source = %q{
doctype 5
  div Invalid
}

    assert_syntax_error "Unexpected indentation\n  (__TEMPLATE__), Line 3, Column 2\n    div Invalid\n    ^\n", source
  end

  def test_malformed_indentation
    source = %q{
p
  div Valid
 div Invalid
}

    assert_syntax_error "Malformed indentation\n  (__TEMPLATE__), Line 4, Column 1\n    div Invalid\n    ^\n", source
  end

  def test_malformed_indentation2
    source = %q{
  div Valid
 div Invalid
}

    assert_syntax_error "Malformed indentation\n  (__TEMPLATE__), Line 3, Column 1\n    div Invalid\n    ^\n", source
  end

  def test_unknown_line_indicator
    source = %q{
p
  div Valid
  .valid
  #valid
  ?invalid
}

    assert_syntax_error "Unknown line indicator\n  (__TEMPLATE__), Line 6, Column 2\n    ?invalid\n    ^\n", source
  end

  def test_expected_closing_delimiter
    source = %q{
p
  img(src="img.jpg" title={title}
}

    assert_syntax_error "Expected closing delimiter )\n  (__TEMPLATE__), Line 3, Column 33\n    img(src=\"img.jpg\" title={title}\n                                   ^\n", source
  end

  def test_missing_quote_unexpected_end
    source = %q{
p
  img(src="img.jpg
}

    assert_syntax_error "Unexpected end of file\n  (__TEMPLATE__), Line 3, Column 0\n    \n    ^\n", source
  end

  def test_expected_closing_attribute_delimiter
    source = %q{
p
  img src=[hash[1] + hash[2]
}

    assert_syntax_error "Expected closing delimiter ]\n  (__TEMPLATE__), Line 3, Column 28\n    img src=[hash[1] + hash[2]\n                              ^\n", source
  end

  def test_invalid_empty_attribute
    source = %q{
p
  img{src= }
}

    assert_syntax_error "Invalid empty attribute\n  (__TEMPLATE__), Line 3, Column 11\n    img{src= }\n             ^\n", source
  end

  def test_invalid_empty_attribute2
    source = %q{
p
  img{src=}
}

    assert_syntax_error "Invalid empty attribute\n  (__TEMPLATE__), Line 3, Column 10\n    img{src=}\n            ^\n", source
  end

  def test_invalid_empty_attribute3
    source = %q{
p
  img src=
}

    assert_syntax_error "Invalid empty attribute\n  (__TEMPLATE__), Line 3, Column 10\n    img src=\n            ^\n", source
  end

  def test_missing_tag_in_block_expansion
    source = %{
html: body:
}

    assert_syntax_error "Expected tag\n  (__TEMPLATE__), Line 2, Column 11\n    html: body:\n               ^\n", source
  end

  def test_invalid_tag_in_block_expansion
    source = %{
html: body: /comment
}
    assert_syntax_error "Expected tag\n  (__TEMPLATE__), Line 2, Column 12\n    html: body: /comment\n                ^\n", source

    source = %{
html: body:/comment
}
    assert_syntax_error "Expected tag\n  (__TEMPLATE__), Line 2, Column 11\n    html: body:/comment\n               ^\n", source
  end

  def test_unexpected_text_after_closed
    source = %{
img / text
}

    assert_syntax_error "Unexpected text after closed tag\n  (__TEMPLATE__), Line 2, Column 6\n    img / text\n          ^\n", source
  end

  def test_illegal_shortcuts
    source = %{
.#test
}

    assert_syntax_error "Illegal shortcut\n  (__TEMPLATE__), Line 2, Column 0\n    .#test\n    ^\n", source

    source = %{
div.#test
}

    assert_syntax_error "Illegal shortcut\n  (__TEMPLATE__), Line 2, Column 3\n    div.#test\n       ^\n", source
  end
end
