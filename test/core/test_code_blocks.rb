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

  def test_render_with_output_code_block_without_do
    source = %q{
p
  = hello_world "Hello Ruby!"
    | Hello from within a block!
}

    assert_html '<p>Hello Ruby! Hello from within a block! Hello Ruby!</p>', source
  end

  def test_render_variable_ending_with_do
    source = %q{
- appelido=10
p= appelido
- appelido
}

    assert_html '<p>10</p>', source
  end


  def test_render_with_output_code_within_block
    source = %q{
p
  = hello_world "Hello Ruby!" do
    = hello_world "Hello from within a block!"
}

    assert_html '<p>Hello Ruby! Hello from within a block! Hello Ruby!</p>', source
  end

  def test_render_with_output_code_within_block_without_do
    source = %q{
p
  = hello_world "Hello Ruby!"
    = hello_world "Hello from within a block!"
}

    assert_html '<p>Hello Ruby! Hello from within a block! Hello Ruby!</p>', source
  end

  def test_render_with_output_code_within_block_2
    source = %q{
p
  = hello_world "Hello Ruby!" do
    = hello_world "Hello from within a block!" do
      = hello_world "And another one!"
}

    assert_html '<p>Hello Ruby! Hello from within a block! And another one! Hello from within a block! Hello Ruby!</p>', source
  end

  def test_render_with_output_code_within_block_2_without_do
    source = %q{
p
  = hello_world "Hello Ruby!"
    = hello_world "Hello from within a block!"
      = hello_world "And another one!"
}

    assert_html '<p>Hello Ruby! Hello from within a block! And another one! Hello from within a block! Hello Ruby!</p>', source
  end

  def test_output_block_with_arguments
    source = %q{
p
  = define_macro :person do |first_name, last_name|
    .first_name = first_name
    .last_name = last_name
  == call_macro :person, 'John', 'Doe'
  == call_macro :person, 'Max', 'Mustermann'
}

    assert_html '<p><div class="first_name">John</div><div class="last_name">Doe</div><div class="first_name">Max</div><div class="last_name">Mustermann</div></p>', source
  end


  def test_render_with_control_code_loop
    source = %q{
p
  - 3.times do
    | Hey!
}

    assert_html '<p>Hey!Hey!Hey!</p>', source
  end

  def test_render_with_control_code_loop_without_do
    source = %q{
p
  - 3.times
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

  def test_captured_code_block_with_conditional_without_do
    source = %q{
= hello_world "Hello Ruby!"
  - if true
    | Hello from within a block!
}

    assert_html 'Hello Ruby! Hello from within a block! Hello Ruby!', source
  end

  def test_if_without_content
    source = %q{
- if true
}
    assert_html '', source
  end

  def test_unless_without_content
    source = %q{
- unless true
}
    assert_html '', source
  end

  def test_if_with_comment
    source = %q{
- if true
  / comment
}
    assert_html '', source
  end

  def test_control_do_with_comment
    source = %q{
- hello_world "Hello"
  / comment
}
    assert_html '', source
  end

  def test_output_do_with_comment
    source = %q{
= hello_world "Hello"
  / comment
}
    assert_html 'Hello', source
  end

  def test_output_if_without_content
    source = %q{
= if true
}
    assert_html '', source
  end

  def test_output_if_with_comment
    source = %q{
= if true
  / comment
}
    assert_html '', source
  end

  def test_output_format_with_if
    source = %q{
h3.subtitle
  - if true
    a href="#" Title true
  - else
    a href="#" Title false
}
    assert_html '<h3 class="subtitle"><a href="#">Title true</a></h3>', source
  end
end
