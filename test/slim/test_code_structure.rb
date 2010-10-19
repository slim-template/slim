require 'helper'

class TestSlimCodeStructure < TestSlim
  def test_render_with_conditional
    string = <<HTML
div
  - if show_first?
      p The first paragraph
  - else
      p The second paragraph
HTML

    expected = "<div><p>The second paragraph</p></div>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_consecutive_conditionals
    string = <<HTML
div
  - if show_first? true
      p The first paragraph
  - if show_first? true
      p The second paragraph
HTML

    expected = "<div><p>The first paragraph</p><p>The second paragraph</p></div>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_parameterized_conditional
    string = <<HTML
div
  - if show_first? false
      p The first paragraph
  - else
      p The second paragraph
HTML

    expected = "<div><p>The second paragraph</p></div>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_inline_condition
    string = <<HTML
p = hello_world if true
HTML

    expected = "<p>Hello World from @env</p>"

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end
end
