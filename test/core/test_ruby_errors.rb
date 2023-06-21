require "helper"

class TestSlimRubyErrors < TestSlim
  def test_multline_attribute
    source = '
p(data-1=1
data2-=1)
  p
    = unknown_ruby_method
'

    assert_ruby_error NameError, "test.slim:5", source, file: "test.slim"
  end

  def test_broken_output_line
    source = '
p = hello_world + \
  hello_world + \
  unknown_ruby_method
'

    assert_ruby_error NameError, "test.slim:4", source, file: "test.slim"
  end

  def test_broken_output_line2
    source = '
p = hello_world + \
  hello_world
p Hello
= unknown_ruby_method
'

    assert_ruby_error NameError, "(__TEMPLATE__):5", source
  end

  def test_output_block
    source = '
p = hello_world "Hello Ruby" do
  = unknown_ruby_method
'

    assert_ruby_error NameError, "(__TEMPLATE__):3", source
  end

  def test_output_block2
    source = '
p = hello_world "Hello Ruby" do
  = "Hello from block"
p Hello
= unknown_ruby_method
'

    assert_ruby_error NameError, "(__TEMPLATE__):5", source
  end

  def test_text_block
    source = '
p Text line 1
  Text line 2
= unknown_ruby_method
'

    assert_ruby_error NameError, "(__TEMPLATE__):4", source
  end

  def test_text_block2
    source = '
|
  Text line 1
  Text line 2
= unknown_ruby_method
'

    assert_ruby_error NameError, "(__TEMPLATE__):5", source
  end

  def test_comment
    source = '
/ Comment line 1
  Comment line 2
= unknown_ruby_method
'

    assert_ruby_error NameError, "(__TEMPLATE__):4", source
  end

  def test_embedded_ruby1
    source = '
ruby:
  a = 1
  b = 2
= a + b
= unknown_ruby_method
'

    assert_ruby_error NameError, "(__TEMPLATE__):7", source
  end

  def test_embedded_ruby2
    source = '
ruby:
  a = 1
  unknown_ruby_method
'

    assert_ruby_error NameError, "(__TEMPLATE__):4", source
  end

  def test_embedded_markdown
    source = %q(
markdown:
  #Header
  Hello from #{"Markdown!"}
  "Second Line!"
= unknown_ruby_method
)

    assert_ruby_error NameError, "(__TEMPLATE__):6", source
  end

  def test_embedded_javascript
    source = '
javascript:
  alert();
  alert();
= unknown_ruby_method
'

    assert_ruby_error NameError, "(__TEMPLATE__):5", source
  end

  def test_invalid_nested_code
    source = '
p
  - test = 123
    = "Hello from within a block! "
'
    assert_ruby_syntax_error "(__TEMPLATE__):3", source
  end

  def test_invalid_nested_output
    source = '
p
  = "Hello Ruby!"
    = "Hello from within a block! "
'
    assert_ruby_syntax_error "(__TEMPLATE__):3", source
  end

  def test_explicit_end
    source = '
div
  - if show_first?
      p The first paragraph
  - end
'

    assert_runtime_error "Explicit end statements are forbidden", source
  end

  def test_multiple_id_attribute
    source = %(
#alpha id="beta" Test it
)
    assert_runtime_error "Multiple id attributes specified", source
  end

  def test_splat_multiple_id_attribute
    source = %(
#alpha *{id:"beta"} Test it
)
    assert_runtime_error "Multiple id attributes specified", source
  end

  #  def test_invalid_option
  #    render('', foobar: 42)
  #    raise Exception, 'ArgumentError expected'
  #  rescue ArgumentError => ex
  #    assert_equal 'Option :foobar is not supported by Slim::Engine', ex.message
  #  end
end
