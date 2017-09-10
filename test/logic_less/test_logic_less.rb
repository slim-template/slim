require 'helper'
require 'slim/logic_less'

class TestSlimLogicLess < TestSlim
  class Scope
    def initialize
      @hash = {
        person: [
                    { name: 'Joe', age: 1, selected: true },
                    { name: 'Jack', age: 2 }
                   ]
      }
    end
  end

  def test_lambda
    source = %q{
p
 == person
  .name = name
 == simple
  .hello= hello
 == list
  li = key
}

    hash = {
      hello: 'Hello!',
      person: lambda do |&block|
        %w(Joe Jack).map do |name|
          "<b>#{block.call(name: name)}</b>"
        end.join
      end,
      simple: lambda do |&block|
        "<div class=\"simple\">#{block.call}</div>"
      end,
      list: lambda do |&block|
        list = [{key: 'First'}, {key: 'Second'}]
        "<ul>#{block.call(*list)}</ul>"
      end
    }

    assert_html '<p><b><div class="name">Joe</div></b><b><div class="name">Jack</div></b><div class="simple"><div class="hello">Hello!</div></div><ul><li>First</li><li>Second</li></ul></p>', source, scope: hash
  end

  def test_symbol_hash
    source = %q{
p
 - person
  .name = name
}

    hash = {
      person: [
        { name: 'Joe', },
        { name: 'Jack', }
      ]
    }

    assert_html '<p><div class="name">Joe</div><div class="name">Jack</div></p>', source, scope: hash
  end

  def test_string_access
    source = %q{
p
 - person
  .name = name
}

    hash = {
      'person' => [
        { 'name' => 'Joe', },
        { 'name' => 'Jack', }
      ]
    }

    assert_html '<p><div class="name">Joe</div><div class="name">Jack</div></p>', source, scope: hash, dictionary_access: :string
  end

  def test_symbol_access
    source = %q{
p
 - person
  .name = name
}

    hash = {
      person: [
        { name: 'Joe', },
        { name: 'Jack', }
      ]
    }

    assert_html '<p><div class="name">Joe</div><div class="name">Jack</div></p>', source, scope: hash, dictionary_access: :symbol
  end

  def test_method_access
    source = %q{
p
 - person
  .name = name
}

    object = Object.new
    def object.person
      %w(Joe Jack).map do |name|
        person = Object.new
        person.instance_variable_set(:@name, name)
        def person.name
          @name
        end
        person
      end
    end

    assert_html '<p><div class="name">Joe</div><div class="name">Jack</div></p>', source, scope: object, dictionary_access: :method
  end

  def test_method_access_without_private
    source = %q{
p
 - person
  .age = age
}

    object = Object.new
    def object.person
      person = Object.new
      def person.age
        42
      end
      person.singleton_class.class_eval { private :age }
      person
    end

    assert_html '<p><div class="age"></div></p>', source, scope: object, dictionary_access: :method
  end

  def test_instance_variable_access
    source = %q{
p
 - person
  .name = name
}

    object = Object.new
    object.instance_variable_set(:@person, %w(Joe Jack).map do |name|
                                   person = Object.new
                                   person.instance_variable_set(:@name, name)
                                   person
                                 end)

    assert_html '<p><div class="name">Joe</div><div class="name">Jack</div></p>', source, scope: object, dictionary_access: :instance_variable
  end

  def test_to_s_access
    source = %q{
p
 - people
  .name = self
}

    hash = {
      people: [
        'Joe',
        'Jack'
      ]
    }

    assert_html '<p><div class="name">Joe</div><div class="name">Jack</div></p>', source, scope: hash, dictionary_access: :symbol
  end

  def test_string_hash
    source = %q{
p
 - person
  .name = name
}

    hash = {
      'person' => [
        { 'name' => 'Joe', },
        { 'name' => 'Jack', }
      ]
    }

    assert_html '<p><div class="name">Joe</div><div class="name">Jack</div></p>', source, scope: hash
  end

  def test_dictionary_option
    source = %q{
p
 - person
  .name = name
}

    assert_html '<p><div class="name">Joe</div><div class="name">Jack</div></p>', source, scope: Scope.new, dictionary: '@hash'
  end

  def test_flag_section
    source = %q{
p
 - show_person
   - person
    .name = name
 - show_person
   | shown
}

    hash = {
      show_person: true,
      person: [
        { name: 'Joe', },
        { name: 'Jack', }
      ]
    }

    assert_html '<p><div class="name">Joe</div><div class="name">Jack</div>shown</p>', source, scope: hash
  end

  def test_inverted_section
    source = %q{
p
 - person
  .name = name
 -! person
  | No person
 - !person
  |  No person 2
}

    hash = {}

    assert_html '<p>No person No person 2</p>', source, scope: hash
  end

  def test_escaped_interpolation
    source = %q{
p text with \#{123} test
}

    assert_html '<p>text with #{123} test</p>', source
  end

  def test_ruby_attributes
    source = %q{
p
 - person
  b name=name Person
  a id=name = age
  span class=name
    Person
}

    assert_html '<p><b name="Joe">Person</b><a id="Joe">1</a><span class="Joe"><Person></Person></span><b name="Jack">Person</b><a id="Jack">2</a><span class="Jack"><Person></Person></span></p>', source, scope: Scope.new, dictionary: '@hash'
  end

  def test_boolean_attributes
    source = %q{
p
 - person
   input checked=selected = name
}

    assert_html '<p><input checked="">Joe</input><input>Jack</input></p>', source, scope: Scope.new, dictionary: '@hash'
  end

  def test_sections
    source = %q{
p
 - person
  .name = name
}
    assert_html '<p><div class="name">Joe</div><div class="name">Jack</div></p>', source, dictionary: 'ViewEnv.new'
  end

  def test_with_array
    source = %q{
ul
 - people_with_locations
  li = name
  li = city
}
    assert_html '<ul><li>Andy</li><li>Atlanta</li><li>Fred</li><li>Melbourne</li><li>Daniel</li><li>Karlsruhe</li></ul>', source, dictionary: 'ViewEnv.new'
  end

  def test_method
    source = %q{
a href=output_number Link
}
    assert_html '<a href="1337">Link</a>', source, dictionary: 'ViewEnv.new'
  end

  def test_conditional_parent
    source = %q{
- prev_page
  li.previous
    a href=prev_page Older
- next_page
  li.next
    a href=next_page Newer}
    assert_html'<li class="previous"><a href="prev">Older</a></li><li class="next"><a href="next">Newer</a></li>', source, scope: {prev_page: 'prev', next_page: 'next'}
  end

  def test_render_with_yield
    source = %q{
div
  == yield
}

    assert_html '<div>This is the menu</div>', source do
      'This is the menu'
    end
  end
end
