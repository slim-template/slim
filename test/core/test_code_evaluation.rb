require 'helper'

class TestSlimCodeEvaluation < TestSlim
  def test_render_with_call_to_set_attributes
    source = %q{
p id="#{id_helper}" class="hello world" = hello_world
}

    assert_html '<p class="hello world" id="notice">Hello World from @env</p>', source
  end

  def test_render_with_call_to_set_custom_attributes
    source = %q{
p data-id="#{id_helper}" data-class="hello world"
  = hello_world
}

    assert_html '<p data-class="hello world" data-id="notice">Hello World from @env</p>', source
  end

  def test_render_with_call_to_set_attributes_and_call_to_set_content
    source = %q{
p id="#{id_helper}" class="hello world" = hello_world
}

    assert_html '<p class="hello world" id="notice">Hello World from @env</p>', source
  end

  def test_render_with_parameterized_call_to_set_attributes_and_call_to_set_content
    source = %q{
p id="#{id_helper}" class="hello world" = hello_world("Hello Ruby!")
}

    assert_html '<p class="hello world" id="notice">Hello Ruby!</p>', source
  end

  def test_render_with_spaced_parameterized_call_to_set_attributes_and_call_to_set_content
    source = %q{
p id="#{id_helper}" class="hello world" = hello_world "Hello Ruby!"
}

    assert_html '<p class="hello world" id="notice">Hello Ruby!</p>', source
  end

  def test_render_with_spaced_parameterized_call_to_set_attributes_and_call_to_set_content_2
    source = %q{
p id="#{id_helper}" class="hello world" = hello_world "Hello Ruby!", dummy: "value"
}

    assert_html '<p class="hello world" id="notice">Hello Ruby!dummy value</p>', source
  end

  def test_hash_call_in_attribute
    source = %q{
p id="#{hash[:a]}" Test it
}

    assert_html '<p id="The letter a">Test it</p>', source
  end

  def test_instance_variable_in_attribute_without_quotes
    source = %q{
p id=@var
}

    assert_html '<p id="instance"></p>', source
  end

  def test_method_call_in_attribute_without_quotes
    source = %q{
form action=action_path(:page, :save) method='post'
}

    assert_html '<form action="/action-page-save" method="post"></form>', source
  end

  def test_ruby_attribute_with_unbalanced_delimiters
    source = %q{
div crazy=action_path('[') id="crazy_delimiters"
}

    assert_html '<div crazy="/action-[" id="crazy_delimiters"></div>', source
  end

  def test_method_call_in_delimited_attribute_without_quotes
    source = %q{
form(action=action_path(:page, :save) method='post')
}

    assert_html '<form action="/action-page-save" method="post"></form>', source
  end

  def test_method_call_in_delimited_attribute_without_quotes2
    source = %q{
form(method='post' action=action_path(:page, :save))
}

    assert_html '<form action="/action-page-save" method="post"></form>', source
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
p id=(hash[:a] + hash[:a]) Test it
}

    assert_html '<p id="The letter aThe letter a">Test it</p>', source
  end

  def test_hash_call_in_delimited_attribute_with_ruby_evaluation
    source = %q{
p(id=(hash[:a] + hash[:a])) Test it
}

    assert_html '<p id="The letter aThe letter a">Test it</p>', source
  end

  def test_hash_call_in_delimited_attribute_with_ruby_evaluation_2
    source = %q{
p[id=(hash[:a] + hash[:a])] Test it
}

    assert_html '<p id="The letter aThe letter a">Test it</p>', source
  end

  def test_hash_call_in_delimited_attribute_with_ruby_evaluation_3
    source = %q{
p(id=(hash[:a] + hash[:a]) class=hash[:a]) Test it
}

    assert_html '<p class="The letter a" id="The letter aThe letter a">Test it</p>', source
  end

  def test_hash_call_in_delimited_attribute_with_ruby_evaluation_4_
    source = %q{
p(id=hash[:a] class=hash[:a]) Test it
}

    assert_html '<p class="The letter a" id="The letter a">Test it</p>', source
  end

  def test_computation_in_attribute
    source = %q{
p id=(1 + 1)*5 Test it
}

    assert_html '<p id="10">Test it</p>', source
  end

  def test_code_attribute_does_not_modify_argument
    require 'ostruct'
    template = 'span class=attribute'
    model = OpenStruct.new(attribute: [:a, :b, [:c, :d]])
    output = Slim::Template.new { template }.render(model)
    assert_equal('<span class="a b c d"></span>', output)
    assert_equal([:a, :b, [:c, :d]], model.attribute)
  end

  def test_number_type_interpolation
    source = %q{
p = output_number
}

    assert_html '<p>1337</p>', source
  end
end
