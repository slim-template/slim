require 'helper'

class TestSlimHtmlStructure < TestSlim
  def test_simple_render
    source = %q{
html
  head
    title Simple Test Title
  body
    p Hello World, meet Slim.
}

    assert_html '<html><head><title>Simple Test Title</title></head><body><p>Hello World, meet Slim.</p></body></html>', source
  end

  def test_html_namespaces
    source = %q{
html:body
  html:p html:id="test" Text
}

    assert_html '<html:body><html:p html:id="test">Text</html:p></html:body>', source
  end

  def test_doctype
    source = %q{
! doctype 5
html
}

    assert_html '<!DOCTYPE html><html></html>', source
  end

  def test_render_with_shortcut_attributes
    source = %q{
h1#title This is my title
#notice.hello.world
  = hello_world
}

    assert_html '<h1 id="title">This is my title</h1><div class="hello world" id="notice">Hello World from @env</div>', source
  end

  def test_render_with_text_block
    source = %q{
p
  `
   Lorem ipsum dolor sit amet, consectetur adipiscing elit.
}

    assert_html '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>', source
  end

  def test_render_with_text_block_with_subsequent_markup
    source = %q{
p
  `
    Lorem ipsum dolor sit amet, consectetur adipiscing elit.
p Some more markup
}

    assert_html '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p><p>Some more markup</p>', source
  end

  def test_nested_text
    source = %q{
p
 |
  This is line one.
   This is line two.
    This is line three.
     This is line four.
p This is a new paragraph.
}

    assert_html '<p>This is line one. This is line two.  This is line three.   This is line four.</p><p>This is a new paragraph.</p>', source
  end

  def test_nested_text_with_nested_html_one_same_line
    source = %q{
p
 | This is line one.
    This is line two.
 span.bold This is a bold line in the paragraph.
 |  This is more content.
}

    assert_html '<p>This is line one. This is line two.<span class="bold">This is a bold line in the paragraph.</span> This is more content.</p>', source
  end

  def test_nested_text_with_nested_html_one_same_line2
    source = %q{
p
 |This is line one.
   This is line two.
 span.bold This is a bold line in the paragraph.
 |  This is more content.
}

    assert_html '<p>This is line one. This is line two.<span class="bold">This is a bold line in the paragraph.</span> This is more content.</p>', source
  end

  def test_nested_text_with_nested_html
    source = %q{
p
 |
  This is line one.
   This is line two.
    This is line three.
     This is line four.
 span.bold This is a bold line in the paragraph.
 |  This is more content.
}

    assert_html '<p>This is line one. This is line two.  This is line three.   This is line four.<span class="bold">This is a bold line in the paragraph.</span> This is more content.</p>', source
  end

  def test_simple_paragraph_with_padding
    source = %q{
p    There will be 3 spaces in front of this line.
}

    assert_html '<p>   There will be 3 spaces in front of this line.</p>', source
  end

  def test_paragraph_with_nested_text
    source = %q{
p This is line one.
   This is line two.
}

    assert_html '<p>This is line one. This is line two.</p>', source
  end

  def test_paragraph_with_padded_nested_text
    source = %q{
p  This is line one.
   This is line two.
}

    assert_html '<p> This is line one. This is line two.</p>', source
  end

  def test_paragraph_with_attributes_and_nested_text
    source = %q{
p#test class="paragraph" This is line one.
                         This is line two.
}

    assert_html '<p class="paragraph" id="test">This is line one.This is line two.</p>', source
  end

  def test_output_code_with_leading_spaces
    source = %q{
p= hello_world
p = hello_world
p    = hello_world
}

    assert_html '<p>Hello World from @env</p><p>Hello World from @env</p><p>Hello World from @env</p>', source
  end

  def test_single_quoted_attributes
    source = %q{
p class='underscored_class_name' = output_number
}

    assert_html '<p class="underscored_class_name">1337</p>', source
 end

  def test_nonstandard_attributes
    source = %q{
p id="dashed-id" class="underscored_class_name" = output_number
}

    assert_html '<p class="underscored_class_name" id="dashed-id">1337</p>', source
  end

  def test_nonstandard_shortcut_attributes
    source = %q{
p#dashed-id.underscored_class_name = output_number
}

    assert_html '<p class="underscored_class_name" id="dashed-id">1337</p>', source
  end

  def test_dashed_attributes
    source = %q{
p data-info="Illudium Q-36" = output_number
}

    assert_html '<p data-info="Illudium Q-36">1337</p>', source
  end

  def test_dashed_attributes_with_shortcuts
    source = %q{
p#marvin.martian data-info="Illudium Q-36" = output_number
}

    assert_html '<p class="martian" data-info="Illudium Q-36" id="marvin">1337</p>', source
  end

  def test_parens_around_attributes
    source = %q{
p(id="marvin" class="martian" data-info="Illudium Q-36") = output_number
}

    assert_html '<p class="martian" data-info="Illudium Q-36" id="marvin">1337</p>', source
  end

  def test_square_brackets_around_attributes
    source = %q{
p[id="marvin" class="martian" data-info="Illudium Q-36"] = output_number
}

    assert_html '<p class="martian" data-info="Illudium Q-36" id="marvin">1337</p>', source
  end

  def test_parens_around_attributes_with_equal_sign_snug_to_right_paren
    source = %q{
p(id="marvin" class="martian" data-info="Illudium Q-36")= output_number
}

    assert_html '<p class="martian" data-info="Illudium Q-36" id="marvin">1337</p>', source
  end
end
