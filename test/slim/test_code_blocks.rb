require 'helper'

class TestSlimCodeBlocks < TestSlim
  def test_render_with_output_code_block
    string = <<HTML
p
  = hello_world "Hello Ruby!" do
    | Hello from within a block!
HTML

    expected = "<p>Hello Ruby! Hello from within a block! Hello Ruby!</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_output_code_within_block
    string = <<HTML
p
  = hello_world "Hello Ruby!" do
    = hello_world "Hello from within a block! "
HTML

    expected = "<p>Hello Ruby! Hello from within a block!  Hello Ruby!</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_control_code_loop
    string = <<HTML
p
  - 3.times do
    | Hey!
HTML

    expected = "<p>Hey!Hey!Hey!</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end
end
