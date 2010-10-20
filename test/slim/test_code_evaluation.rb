require 'helper'

class TestSlimCodeEvaluation < TestSlim
  def test_render_with_call_to_set_attributes
    source = %q{
p id="#{id_helper}" class="hello world" = hello_world
}

    assert_html '<p id="notice" class="hello world">Hello World from @env</p>', source
  end

  def test_render_with_call_to_set_custom_attributes
    source = %q{
p data-id="#{id_helper}" data-class="hello world"
  = hello_world
}

    assert_html '<p data-id="notice" data-class="hello world">Hello World from @env</p>', source
  end

  def test_render_with_call_to_set_attributes_and_call_to_set_content
    source = %q{
p id="#{id_helper}" class="hello world" = hello_world
}

    assert_html '<p id="notice" class="hello world">Hello World from @env</p>', source
  end

  def test_render_with_parameterized_call_to_set_attributes_and_call_to_set_content
    source = %q{
p id="#{id_helper}" class="hello world" = hello_world("Hello Ruby!")
}

    assert_html '<p id="notice" class="hello world">Hello Ruby!</p>', source
  end

  def test_render_with_spaced_parameterized_call_to_set_attributes_and_call_to_set_content
    source = %q{
p id="#{id_helper}" class="hello world" = hello_world "Hello Ruby!"
}

    assert_html '<p id="notice" class="hello world">Hello Ruby!</p>', source
  end

  def test_render_with_spaced_parameterized_call_to_set_attributes_and_call_to_set_content_2
    source = %q{
p id="#{id_helper}" class="hello world" = hello_world "Hello Ruby!", :dummy => "value"
}

    assert_html '<p id="notice" class="hello world">Hello Ruby!dummy value</p>', source
  end

  def test_hash_call_in_attribute
    source = %q{
p id="#{hash[:a]}" Test it
}

    assert_html '<p id="The letter a">Test it</p>', source
  end

  def test_hash_call_in_attribute_without_quotes
    source = %q{
p id=hash[:a] Test it
}

    assert_html '<p id="The letter a">Test it</p>', source
  end

  def test_hash_call_in_delimited_attribute
    source = %q{
p(id=hash[:a]) Test it
}

    assert_html '<p id="The letter a">Test it</p>', source
  end

  def test_hash_call_in_attribute_with_ruby_evaluation
    source = %q{
p id=(hash[:a]+hash[:a]) Test it
}

    assert_html '<p id="The letter aThe letter a">Test it</p>', source
  end

  def test_hash_call_in_delimited_attribute_with_ruby_evaluation
    source = %q{
p(id=(hash[:a]+hash[:a])) Test it
}

    assert_html '<p id="The letter aThe letter a">Test it</p>', source
  end

  def test_hash_call_in_delimited_attribute_with_ruby_evaluation_2
    source = %q{
p[id=(hash[:a]+hash[:a])] Test it
}

    assert_html '<p id="The letter aThe letter a">Test it</p>', source
  end

  def test_hash_call_in_delimited_attribute_with_ruby_evaluation_3
    source = %q{
p(id=[hash[:a]+hash[:a]]) Test it
}

    assert_html '<p id="The letter aThe letter a">Test it</p>', source
  end

  def test_hash_call_in_delimited_attribute_with_ruby_evaluation_4
    source = %q{
p(id=[hash[:a]+hash[:a]] class=[hash[:a]]) Test it
}

    assert_html '<p id="The letter aThe letter a" class="The letter a">Test it</p>', source
  end

  def test_hash_call_in_delimited_attribute_with_ruby_evaluation_5
    source = %q{
p(id=hash[:a] class=[hash[:a]]) Test it
}

    assert_html '<p id="The letter a" class="The letter a">Test it</p>', source
  end

  def test_interpolation_in_text
    source = %q{
p
 | #{hello_world}
p
 |
  A message from the compiler: #{hello_world}
}

    assert_html '<p>Hello World from @env</p><p>A message from the compiler: Hello World from @env</p>', source
  end

  def test_interpolation_in_tag
    source = %q{
p #{hello_world}
}

    assert_html '<p>Hello World from @env</p>', source
  end

  def test_number_type_interpolation
    source = %q{
p = output_number
}

    assert_html '<p>1337</p>', source
  end

  def test_ternary_operation_in_attribute
    source = %q{
p id="#{(false ? 'notshown' : 'shown')}" = output_number
}

    assert_html '<p id="shown">1337</p>', source
  end
end
