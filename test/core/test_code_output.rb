require "helper"

class TestSlimCodeOutput < TestSlim
  def test_render_with_call
    source = '
p
  = hello_world
'

    assert_html "<p>Hello World from @env</p>", source
  end

  def test_render_with_trailing_whitespace
    source = '
p
  => hello_world
'

    assert_html "<p>Hello World from @env </p>", source
  end

  def test_render_with_trailing_whitespace_after_tag
    source = '
p=> hello_world
'

    assert_html "<p>Hello World from @env</p> ", source
  end

  def test_no_escape_render_with_trailing_whitespace
    source = '
p
  ==> hello_world
'

    assert_html "<p>Hello World from @env </p>", source
  end

  def test_no_escape_render_with_trailing_whitespace_after_tag
    source = '
p==> hello_world
'

    assert_html "<p>Hello World from @env</p> ", source
  end

  def test_render_with_conditional_call
    source = '
p
  = hello_world if true
'

    assert_html "<p>Hello World from @env</p>", source
  end

  def test_render_with_parameterized_call
    source = '
p
  = hello_world("Hello Ruby!")
'

    assert_html "<p>Hello Ruby!</p>", source
  end

  def test_render_with_spaced_parameterized_call
    source = '
p
  = hello_world "Hello Ruby!"
'

    assert_html "<p>Hello Ruby!</p>", source
  end

  def test_render_with_spaced_parameterized_call_2
    source = '
p
  = hello_world "Hello Ruby!", dummy: "value"
'

    assert_html "<p>Hello Ruby!dummy value</p>", source
  end

  def test_render_with_call_and_inline_text
    source = '
h1 This is my title
p
  = hello_world
'

    assert_html "<h1>This is my title</h1><p>Hello World from @env</p>", source
  end

  def test_render_with_attribute_starts_with_keyword
    source = '
p = hello_world in_keyword
'

    assert_html "<p>starts with keyword</p>", source
  end

  def test_hash_call
    source = '
p = hash[:a]
'

    assert_html "<p>The letter a</p>", source
  end

  def test_tag_output_without_space
    source = '
p= hello_world
p=hello_world
'

    assert_html "<p>Hello World from @env</p><p>Hello World from @env</p>", source
  end

  def test_class_output_without_space
    source = '
.test=hello_world
#test==hello_world
'

    assert_html '<div class="test">Hello World from @env</div><div id="test">Hello World from @env</div>', source
  end

  def test_attribute_output_without_space
    source = '
p id="test"=hello_world
p(id="test")==hello_world
'

    assert_html '<p id="test">Hello World from @env</p><p id="test">Hello World from @env</p>', source
  end

  def test_render_with_backslash_end
    # Keep trailing spaces!
    source = '
p = \
"Hello" + \
" Ruby!"
- variable = 1 + \
      2 + \
 3
= variable + \
  1
'

    assert_html "<p>Hello Ruby!</p>7", source
  end

  def test_render_with_comma_end
    source = '
p = message("Hello",
            "Ruby!")
'

    assert_html "<p>Hello Ruby!</p>", source
  end

  def test_render_with_no_trailing_character
    source = '
p
  = hello_world'

    assert_html "<p>Hello World from @env</p>", source
  end
end
