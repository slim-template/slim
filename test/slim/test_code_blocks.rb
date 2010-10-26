require 'helper'

class TestSlimCodeBlocks < TestSlim
  def test_render_with_output_code_block
    source = %q{
p
  = hello_world "Hello Ruby!" do
    | Hello from within a block!
}

    assert_html '<p>Hello Ruby! Hello from within a block! Hello Ruby!</p>', source
  end

  def test_render_with_output_code_within_block
    source = %q{
p
  = hello_world "Hello Ruby!" do
    = hello_world "Hello from within a block! "
}

    assert_html '<p>Hello Ruby! Hello from within a block!  Hello Ruby!</p>', source
  end

  def test_render_with_control_code_loop
    source = %q{
p
  - 3.times do
    | Hey!
}

    assert_html '<p>Hey!Hey!Hey!</p>', source
  end

  def test_captured_code_block_with_conditional
    source = %q{
= hello_world "Hello Ruby!" do
  - if true
    | Hello from within a block!
}

    assert_html 'Hello Ruby! Hello from within a block! Hello Ruby!', source
  end
end
