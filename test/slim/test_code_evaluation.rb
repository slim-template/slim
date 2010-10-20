require 'helper'

class TestSlimCodeEvaluation < TestSlim
  def test_render_with_call_to_set_attributes
    string = <<HTML
p id="#\{id_helper}" class="hello world" = hello_world
HTML

    expected = '<p id="notice" class="hello world">Hello World from @env</p>'

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_call_to_set_custom_attributes
    string = <<HTML
p data-id="#\{id_helper}" data-class="hello world"
  = hello_world
HTML

    expected = '<p data-id="notice" data-class="hello world">Hello World from @env</p>'

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_call_to_set_attributes_and_call_to_set_content
    string = <<HTML
p id="#\{id_helper}" class="hello world" = hello_world
HTML

    expected = '<p id="notice" class="hello world">Hello World from @env</p>'

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_parameterized_call_to_set_attributes_and_call_to_set_content
    string = <<HTML
p id="#\{id_helper}" class="hello world" = hello_world("Hello Ruby!")
HTML

    expected = '<p id="notice" class="hello world">Hello Ruby!</p>'

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_spaced_parameterized_call_to_set_attributes_and_call_to_set_content
    string = <<HTML
p id="#\{id_helper}" class="hello world" = hello_world "Hello Ruby!"
HTML

    expected = '<p id="notice" class="hello world">Hello Ruby!</p>'

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_with_spaced_parameterized_call_to_set_attributes_and_call_to_set_content_2
    string = <<HTML
p id="#\{id_helper}" class="hello world" = hello_world "Hello Ruby!", :dummy => "value"
HTML

    expected = '<p id="notice" class="hello world">Hello Ruby!dummy value</p>'

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_hash_call_in_attribute
    string = <<HTML
p id="#\{hash[:a]}" Test it
HTML

    expected = '<p id="The letter a">Test it</p>'

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_hash_call_in_attribute_without_quotes
    string = <<HTML
p id=hash[:a] Test it
HTML

    expected = '<p id="The letter a">Test it</p>'

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_hash_call_in_delimited_attribute
    string = <<HTML
p(id=hash[:a]) Test it
HTML

    expected = '<p id="The letter a">Test it</p>'

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_hash_call_in_attribute_with_ruby_evaluation
    string = <<HTML
p id=(hash[:a]+hash[:a]) Test it
HTML

    expected = '<p id="The letter aThe letter a">Test it</p>'

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_hash_call_in_delimited_attribute_with_ruby_evaluation
    string = <<HTML
p(id=(hash[:a]+hash[:a])) Test it
HTML

    expected = '<p id="The letter aThe letter a">Test it</p>'

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_hash_call_in_delimited_attribute_with_ruby_evaluation_2
    string = <<HTML
p[id=(hash[:a]+hash[:a])] Test it
HTML

    expected = '<p id="The letter aThe letter a">Test it</p>'

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_hash_call_in_delimited_attribute_with_ruby_evaluation_3
    string = <<HTML
p(id=[hash[:a]+hash[:a]]) Test it
HTML

    expected = '<p id="The letter aThe letter a">Test it</p>'

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_hash_call_in_delimited_attribute_with_ruby_evaluation_4
    string = <<HTML
p(id=[hash[:a]+hash[:a]] class=[hash[:a]]) Test it
HTML

    expected = '<p id="The letter aThe letter a" class="The letter a">Test it</p>'

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_hash_call_in_delimited_attribute_with_ruby_evaluation_5
    string = <<HTML
p(id=hash[:a] class=[hash[:a]]) Test it
HTML

    expected = '<p id="The letter a" class="The letter a">Test it</p>'

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_interpolation_in_text
    string = <<HTML
p
 | \#{hello_world}
p
 |
  A message from the compiler: \#{hello_world}
HTML

    expected = '<p>Hello World from @env</p><p>A message from the compiler: Hello World from @env</p>'

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_interpolation_in_tag
    string = <<HTML
p \#{hello_world}
HTML

    expected = '<p>Hello World from @env</p>'

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_number_type_interpolation
    string = <<HTML
p = output_number
HTML

    expected = '<p>1337</p>'

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_ternary_operation_in_attribute
    string = <<HTML
p id="\#{(false ? 'notshown' : 'shown')}" = output_number
HTML

    expected = '<p id="shown">1337</p>'

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end
end
