require 'helper'

class TestSlimHtmlStructure < TestSlim
  def test_simple_render
    # Keep the trailing space behind "body "!
    source = %q{
html
  head
    title Simple Test Title
  body 
    p Hello World, meet Slim.
}

    assert_html '<html><head><title>Simple Test Title</title></head><body><p>Hello World, meet Slim.</p></body></html>', source
  end

  def test_relaxed_indentation_of_first_line
    source = %q{
  p
    .content
}

    assert_html "<p><div class=\"content\"></div></p>", source
  end

  def test_html_tag_with_text_and_empty_line
    source = %q{
p Hello

p World
}

    assert_html "<p>Hello</p><p>World</p>", source
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
doctype 1.1
html
}

    assert_html '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"><html></html>', source, format: :xhtml
  end

  def test_doctype_new_syntax
    source = %q{
doctype 5
html
}

    assert_html '<!DOCTYPE html><html></html>', source, format: :xhtml
  end

  def test_doctype_new_syntax_html5
    source = %q{
doctype html
html
}

    assert_html '<!DOCTYPE html><html></html>', source, format: :xhtml
  end

  def test_render_with_shortcut_attributes
    source = %q{
h1#title This is my title
#notice.hello.world
  = hello_world
}

    assert_html '<h1 id="title">This is my title</h1><div class="hello world" id="notice">Hello World from @env</div>', source
  end

  def test_render_with_overwritten_default_tag
    source = %q{
#notice.hello.world
   = hello_world
 }

    assert_html '<section class="hello world" id="notice">Hello World from @env</section>', source, default_tag: 'section'
  end

  def test_render_with_custom_shortcut
    source = %q{
#notice.hello.world@test
  = hello_world
@abc
  = hello_world
}

    assert_html '<div class="hello world" id="notice" role="test">Hello World from @env</div><section role="abc">Hello World from @env</section>', source, shortcut: {'#' => {attr: 'id'}, '.' => {attr: 'class'}, '@' => {tag: 'section', attr: 'role'}}
  end

  def test_render_with_custom_array_shortcut
    source = %q{
#user@.admin Daniel
}
    assert_html '<div class="admin" id="user" role="admin">Daniel</div>', source, shortcut: {'#' => {attr: 'id'}, '.' => {attr: 'class'}, '@' => {attr: 'role'}, '@.' => {attr: ['class', 'role']}}
  end

  def test_render_with_custom_shortcut_and_additional_attrs
    source = %q{
^items
  == "[{'title':'item0'},{'title':'item1'},{'title':'item2'},{'title':'item3'},{'title':'item4'}]"
}
    assert_html '<script data-binding="items" type="application/json">[{\'title\':\'item0\'},{\'title\':\'item1\'},{\'title\':\'item2\'},{\'title\':\'item3\'},{\'title\':\'item4\'}]</script>',
                source, shortcut: {'^' => {tag: 'script', attr: 'data-binding', additional_attrs: { type: "application/json" }}}
  end

  def test_render_with_custom_lambda_shortcut
    begin
      Slim::Parser.options[:shortcut]['~'] = {attr: ->(v) {{class: "styled-#{v}", id: "id-#{v}"}}}
      source = %q{
~foo Hello
}
      assert_html '<div class="styled-foo" id="id-foo">Hello</div>', source
    ensure
      Slim::Parser.options[:shortcut].delete('~')
    end
  end

  def test_render_with_custom_lambda_shortcut_and_multiple_values
    begin
      Slim::Parser.options[:shortcut]['~'] = {attr: ->(v) {{class: "styled-#{v}"}}}
      source = %q{
~foo~bar Hello
}
      assert_html '<div class="styled-foo styled-bar">Hello</div>', source
    ensure
      Slim::Parser.options[:shortcut].delete('~')
    end
  end

  def test_render_with_custom_lambda_shortcut_and_existing_class
    begin
      Slim::Parser.options[:shortcut]['~'] = {attr: ->(v) {{class: "styled-#{v}"}}}
      source = %q{
~foo.baz Hello
}
      assert_html '<div class="styled-foo baz">Hello</div>', source
    ensure
      Slim::Parser.options[:shortcut].delete('~')
    end
  end

  def test_render_with_existing_class_and_custom_lambda_shortcut
    begin
      Slim::Parser.options[:shortcut]['~'] = {attr: ->(v) {{class: "styled-#{v}"}}}
      source = %q{
.baz~foo Hello
}
      assert_html '<div class="baz styled-foo">Hello</div>', source
    ensure
      Slim::Parser.options[:shortcut].delete('~')
    end
  end

  def test_render_with_text_block
    source = %q{
p
  |
   Lorem ipsum dolor sit amet, consectetur adipiscing elit.
}

    assert_html '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>', source
  end

  def test_render_with_text_block_with_subsequent_markup
    source = %q{
p
  |
    Lorem ipsum dolor sit amet, consectetur adipiscing elit.
p Some more markup
}

    assert_html '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p><p>Some more markup</p>', source
  end

  def test_render_with_text_block_with_trailing_whitespace
    source = %q{
' this is
  a link to
a href="link" page
}

    assert_html "this is\na link to <a href=\"link\">page</a>", source
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

    assert_html "<p>This is line one.\n This is line two.\n  This is line three.\n   This is line four.</p><p>This is a new paragraph.</p>", source
  end

  def test_nested_text_with_nested_html_one_same_line
    source = %q{
p
 | This is line one.
    This is line two.
 span.bold This is a bold line in the paragraph.
 |  This is more content.
}

    assert_html "<p>This is line one.\n This is line two.<span class=\"bold\">This is a bold line in the paragraph.</span> This is more content.</p>", source
  end

  def test_nested_text_with_nested_html_one_same_line2
    source = %q{
p
 |This is line one.
   This is line two.
 span.bold This is a bold line in the paragraph.
 |  This is more content.
}

    assert_html "<p>This is line one.\n This is line two.<span class=\"bold\">This is a bold line in the paragraph.</span> This is more content.</p>", source
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

    assert_html "<p>This is line one.\n This is line two.\n  This is line three.\n   This is line four.<span class=\"bold\">This is a bold line in the paragraph.</span> This is more content.</p>", source
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

    assert_html "<p>This is line one.\n This is line two.</p>", source
  end

  def test_paragraph_with_padded_nested_text
    source = %q{
p  This is line one.
   This is line two.
}

    assert_html "<p> This is line one.\n This is line two.</p>", source
  end

  def test_paragraph_with_attributes_and_nested_text
    source = %q{
p#test class="paragraph" This is line one.
                         This is line two.
}

    assert_html "<p class=\"paragraph\" id=\"test\">This is line one.\nThis is line two.</p>", source
  end

  def test_relaxed_text_indentation
    source = %q{
p
  | text block
   text
    line3
}

    assert_html "<p>text block\ntext\n line3</p>", source
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

  # Regression test for bug #796
  def test_square_brackets_around_attributes_multiline_with_tabs
    source = "div\n\tp[\n\t\tclass=\"martian\"\n\t]\n\tp Next line"
    assert_html '<div><p class="martian"></p><p>Next line</p></div>', source
  end

  def test_parens_around_attributes_with_equal_sign_snug_to_right_paren
    source = %q{
p(id="marvin" class="martian" data-info="Illudium Q-36")= output_number
}

    assert_html '<p class="martian" data-info="Illudium Q-36" id="marvin">1337</p>', source
  end

  def test_default_attr_delims_option
    source = %q{
p<id="marvin" class="martian" data-info="Illudium Q-36">= output_number
}
    Slim::Parser.options[:attr_list_delims].each do |k,v|
      str = source.sub('<',k).sub('>',v)
      assert_html '<p class="martian" data-info="Illudium Q-36" id="marvin">1337</p>', str
    end
  end

  def test_custom_attr_delims_option
    source = %q{
p { foo="bar" }
}

    assert_html '<p foo="bar"></p>', source
    assert_html '<p foo="bar"></p>', source, attr_list_delims: {'{' => '}'}
    assert_html '<p>{ foo="bar" }</p>', source, attr_list_delims: {'(' => ')', '[' => ']'}
  end

  def test_closed_tag
    source = %q{
closed/
}

    assert_html '<closed />', source, format: :xhtml
  end

  def test_custom_attr_list_delims_option
    source = %q{
p { foo="bar" x=(1+1) }
p < x=(1+1) > Hello
}

    assert_html '<p foo="bar" x="2"></p><p>< x=(1+1) > Hello</p>', source
    assert_html '<p foo="bar" x="2"></p><p>< x=(1+1) > Hello</p>', source, attr_list_delims: {'{' => '}'}
    assert_html '<p>{ foo="bar" x=(1+1) }</p><p x="2">Hello</p>', source, attr_list_delims: {'<' => '>'}, code_attr_delims: { '(' => ')' }
  end

  def test_attributs_with_parens_and_spaces
    source = %q{label{ for='filter' }= hello_world}
    assert_html '<label for="filter">Hello World from @env</label>', source
  end

  def test_attributs_with_parens_and_spaces2
    source = %q{label{ for='filter' } = hello_world}
    assert_html '<label for="filter">Hello World from @env</label>', source
  end

  def test_attributs_with_multiple_spaces
    source = %q{label  for='filter'  class="test" = hello_world}
    assert_html '<label class="test" for="filter">Hello World from @env</label>', source
  end

  def test_closed_tag_with_attributes
    source = %q{
closed id="test" /
}

    assert_html '<closed id="test" />', source, format: :xhtml
  end

  def test_closed_tag_with_attributes_and_parens
    source = %q{
closed(id="test")/
}

    assert_html '<closed id="test" />', source, format: :xhtml
  end

  def test_render_with_html_comments
    source = %q{
p Hello
/! This is a comment

   Another comment
p World
}

    assert_html "<p>Hello</p><!--This is a comment\n\nAnother comment--><p>World</p>", source
  end

  def test_render_with_html_conditional_and_tag
    source = %q{
/[ if IE ]
 p Get a better browser.
}

    assert_html "<!--[if IE]><p>Get a better browser.</p><![endif]-->", source
  end

  def test_render_with_html_conditional_and_method_output
    source = %q{
/[ if IE ]
 = message 'hello'
}

    assert_html "<!--[if IE]>hello<![endif]-->", source
  end

  def test_multiline_attributes_with_method
    source = %q{
p<id="marvin"
class="martian"
 data-info="Illudium Q-36"> = output_number
}
    Slim::Parser.options[:attr_list_delims].each do |k,v|
      str = source.sub('<',k).sub('>',v)
      assert_html '<p class="martian" data-info="Illudium Q-36" id="marvin">1337</p>', str
    end
  end

  def test_multiline_attributes_with_text_on_same_line
    source = %q{
p<id="marvin"
  class="martian"
 data-info="Illudium Q-36"> THE space modulator
}
    Slim::Parser.options[:attr_list_delims].each do |k,v|
      str = source.sub('<',k).sub('>',v)
      assert_html '<p class="martian" data-info="Illudium Q-36" id="marvin">THE space modulator</p>', str
    end
  end

  def test_multiline_attributes_with_nested_text
    source = %q{
p<id="marvin"
  class="martian"
data-info="Illudium Q-36">
  | THE space modulator
}
    Slim::Parser.options[:attr_list_delims].each do |k,v|
      str = source.sub('<',k).sub('>',v)
      assert_html '<p class="martian" data-info="Illudium Q-36" id="marvin">THE space modulator</p>', str
    end
  end

  def test_multiline_attributes_with_dynamic_attr
    source = %q{
p<id=id_helper
  class="martian"
  data-info="Illudium Q-36">
  | THE space modulator
}
    Slim::Parser.options[:attr_list_delims].each do |k,v|
      str = source.sub('<',k).sub('>',v)
      assert_html '<p class="martian" data-info="Illudium Q-36" id="notice">THE space modulator</p>', str
    end
  end

  def test_multiline_attributes_with_nested_tag
    source = %q{
p<id=id_helper
  class="martian"
  data-info="Illudium Q-36">
  span.emphasis THE
  |  space modulator
}
    Slim::Parser.options[:attr_list_delims].each do |k,v|
      str = source.sub('<',k).sub('>',v)
      assert_html '<p class="martian" data-info="Illudium Q-36" id="notice"><span class="emphasis">THE</span> space modulator</p>', str
    end
  end

  def test_multiline_attributes_with_nested_text_and_extra_indentation
    source = %q{
li< id="myid"
    class="myclass"
data-info="myinfo">
  a href="link" My Link
}
    Slim::Parser.options[:attr_list_delims].each do |k,v|
      str = source.sub('<',k).sub('>',v)
      assert_html '<li class="myclass" data-info="myinfo" id="myid"><a href="link">My Link</a></li>', str
    end
  end

  def test_block_expansion_support
    source = %q{
ul
  li.first: a href='a' foo
  li:       a href='b' bar
  li.last:  a href='c' baz
}
    assert_html %{<ul><li class=\"first\"><a href=\"a\">foo</a></li><li><a href=\"b\">bar</a></li><li class=\"last\"><a href=\"c\">baz</a></li></ul>}, source
  end

  def test_block_expansion_class_attributes
    source = %q{
.a: .b: #c d
}
    assert_html %{<div class="a"><div class="b"><div id="c">d</div></div></div>}, source
  end

  def test_block_expansion_nesting
    source = %q{
html: body: .content
  | Text
}
    assert_html %{<html><body><div class=\"content\">Text</div></body></html>}, source
  end

  def test_eval_attributes_once
    source = %q{
input[value=succ_x]
input[value=succ_x]
}
    assert_html %{<input value="1" /><input value="2" />}, source
  end

  def test_html_line_indicator
    source = %q{
<html>
  head
    meta name="keywords" content=hello_world
  - if true
    <p>#{hello_world}</p>
      span = hello_world
</html>
    }

    assert_html '<html><head><meta content="Hello World from @env" name="keywords" /></head><p>Hello World from @env</p><span>Hello World from @env</span></html>', source
  end
end
