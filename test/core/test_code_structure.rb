require 'helper'

class TestSlimCodeStructure < TestSlim
  def test_render_with_conditional
    source = %q{
div
  - if show_first?
      p The first paragraph
  - else
      p The second paragraph
}

    assert_html '<div><p>The second paragraph</p></div>', source
  end

  def test_render_with_begin
    source = %q{
- if true
  - begin
    p A
- if true
  - begin
    p B
- if true
  - begin
    p C
  - rescue
    p D
}

    assert_html '<p>A</p><p>B</p><p>C</p>', source
  end

  def test_render_with_consecutive_conditionals
    source = %q{
div
  - if show_first? true
      p The first paragraph
  - if show_first? true
      p The second paragraph
}

    assert_html '<div><p>The first paragraph</p><p>The second paragraph</p></div>', source
  end

  def test_render_with_parameterized_conditional
    source = %q{
div
  - if show_first? false
      p The first paragraph
  - else
      p The second paragraph
}

    assert_html '<div><p>The second paragraph</p></div>', source
  end

  def test_render_with_when_string_in_condition
    source = %q{
- if true
  | Hello

- unless 'when' == nil
  |  world
}

    assert_html 'Hello world', source
  end

  def test_render_with_conditional_and_following_nonconditonal
    source = %q{
div
  - if true
      p The first paragraph
  - var = 42
  = var
}

    assert_html '<div><p>The first paragraph</p>42</div>', source
  end

  def test_render_with_inline_condition
    source = %q{
p = hello_world if true
}

    assert_html '<p>Hello World from @env</p>', source
  end

  def test_render_with_case
    source = %q{
p
  - case 42
  - when 41
    | 41
  - when 42
    | 42
  |  is the answer
p
  - case 41
  - when 41
    | 41
  - when 42
    | 42
  |  is the answer
p
  - case 42 when 41
    | 41
  - when 42
    | 42
  |  is the answer
p
  - case 41 when 41
    | 41
  - when 42
    | 42
  |  is the answer
}

    assert_html '<p>42 is the answer</p><p>41 is the answer</p><p>42 is the answer</p><p>41 is the answer</p>', source
  end

  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.7")
    def test_render_with_case_in
      source = %q{
  p
    - case [:greet, "world"]
    - in :greet, value if false
      = "Goodbye #{value}"
    - in :greet, value unless true
      = "Top of the morning to you, #{value}"
    - in :greet, value
      = "Hello #{value}"
  }

      assert_html '<p>Hello world</p>', source
    end
  end

  def test_render_with_slim_comments
    source = %q{
p Hello
/ This is a comment
  Another comment
p World
}

    assert_html '<p>Hello</p><p>World</p>', source
  end

  def test_render_with_yield
    source = %q{
div
  == yield :menu
}

    assert_html '<div>This is the menu</div>', source do
      'This is the menu'
    end
  end

  def test_render_with_begin_rescue
    source = %q{
- begin
  p Begin
- rescue
  p Rescue
p After
}

    assert_html '<p>Begin</p><p>After</p>', source
  end

  def test_render_with_begin_rescue_exception
    source = %q{
- begin
  p Begin
  - raise 'Boom'
  p After Boom
- rescue => ex
  p = ex.message
p After
}

    assert_html '<p>Begin</p><p>Boom</p><p>After</p>', source
  end

  def test_render_with_begin_rescue_ensure
    source = %q{
- begin
  p Begin
  - raise 'Boom'
  p After Boom
- rescue => ex
  p = ex.message
- ensure
  p Ensure
p After
}

    assert_html '<p>Begin</p><p>Boom</p><p>Ensure</p><p>After</p>', source
  end
end
