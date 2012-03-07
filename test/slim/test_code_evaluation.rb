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
p id="#{id_helper}" class="hello world" = hello_world "Hello Ruby!", :dummy => "value"
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

    assert_html '<form action="&#47;action-page-save" method="post"></form>', source
  end

  def test_ruby_attribute_with_unbalanced_delimiters
    source = %q{
div crazy=action_path('[') id="crazy_delimiters"
}

    assert_html '<div crazy="&#47;action-[" id="crazy_delimiters"></div>', source
  end

  def test_method_call_in_delimited_attribute_without_quotes
    source = %q{
form(action=action_path(:page, :save) method='post')
}

    assert_html '<form action="&#47;action-page-save" method="post"></form>', source
  end

  def test_method_call_in_delimited_attribute_without_quotes2
    source = %q{
form(method='post' action=action_path(:page, :save))
}

    assert_html '<form action="&#47;action-page-save" method="post"></form>', source
  end

  def test_bypassing_escape_in_attribute
    source = %q{
form action==action_path(:page, :save) method='post'
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
p id={hash[:a] + hash[:a]} Test it
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
p(id=[hash[:a] + hash[:a]]) Test it
}

    assert_html '<p id="The letter aThe letter a">Test it</p>', source
  end

  def test_hash_call_in_delimited_attribute_with_ruby_evaluation_4
    source = %q{
p(id=[hash[:a] + hash[:a]] class=[hash[:a]]) Test it
}

    assert_html '<p class="The letter a" id="The letter aThe letter a">Test it</p>', source
  end

  def test_hash_call_in_delimited_attribute_with_ruby_evaluation_5
    source = %q{
p(id=hash[:a] class=[hash[:a]]) Test it
}

    assert_html '<p class="The letter a" id="The letter a">Test it</p>', source
  end

  def test_computation_in_attribute
    source = %q{
p id=(1 + 1)*5 Test it
}

    assert_html '<p id="10">Test it</p>', source
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

  def test_ternary_operation_in_attribute_2
    source = %q{
p id=(false ? 'notshown' : 'shown') = output_number
}

    assert_html '<p id="shown">1337</p>', source
  end

  def test_class_attribute_merging
    source = %{
.alpha class="beta" Test it
}
    assert_html '<div class="alpha beta">Test it</div>', source
  end

  def test_class_attribute_merging_with_nil
    source = %{
.alpha class="beta" class=nil class="gamma" Test it
}
    assert_html '<div class="alpha beta gamma">Test it</div>', source
  end

  def test_id_attribute_merging
    source = %{
#alpha id="beta" Test it
}
    assert_html '<div id="alpha_beta">Test it</div>', source, :attr_delimiter => {'class' => ' ', 'id' => '_' }
  end

  def test_id_attribute_merging2
    source = %{
#alpha id="beta" Test it
}
    assert_html '<div id="alpha-beta">Test it</div>', source, :attr_delimiter => {'class' => ' ', 'id' => '-' }
  end

  def test_boolean_attribute_false
    source = %{
option selected=false Text
}

    assert_html '<option>Text</option>', source
  end

  def test_boolean_attribute_true
    source = %{
option selected=true Text
}

    assert_html '<option selected="selected">Text</option>', source
  end

  def test_boolean_attribute_dynamic
    source = %{
option selected=method_which_returns_true Text
}

    assert_html '<option selected="selected">Text</option>', source
  end

  def test_boolean_attribute_nil
    source = %{
option selected=nil Text
}

    assert_html '<option>Text</option>', source
  end

  def test_boolean_attribute_string2
    source = %{
option selected="selected" Text
}

    assert_html '<option selected="selected">Text</option>', source
  end

  def test_boolean_attribute_shortcut
    source = %{
option(class="clazz" selected) Text
option(selected class="clazz") Text
}

    assert_html '<option class="clazz" selected="selected">Text</option><option class="clazz" selected="selected">Text</option>', source
  end

  def test_array_attribute
    source = %{
.alpha class="beta" class=[:gamma, nil, :delta, [true, false]]
}

    assert_html '<div class="alpha beta gamma delta true false"></div>', source
  end
end
