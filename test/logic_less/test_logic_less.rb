require 'helper'
require 'slim/logic_less'

class TestSlimLogicLess < TestSlim
  class Scope
    def initialize
      @hash = {
        :person => [
                    { :name => 'Joe', :age => 1, :selected => true },
                    { :name => 'Jack', :age => 2 }
                   ]
      }
    end
  end

  def test_lambda
    source = %q{
p
 - person
  .name = name
}

    hash = {
      :person => lambda do |&block|
        %w(Joe Jack).each do |name|
          block.call(:name => name)
        end
      end
    }

    assert_html '<p><div class="name">Joe</div><div class="name">Jack</div></p>', source, :scope => hash
  end

  def test_symbol_hash
    source = %q{
p
 - person
  .name = name
}

    hash = {
      :person => [
        { :name => 'Joe', },
        { :name => 'Jack', }
      ]
    }

    assert_html '<p><div class="name">Joe</div><div class="name">Jack</div></p>', source, :scope => hash
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

    assert_html '<p><div class="name">Joe</div><div class="name">Jack</div></p>', source, :scope => hash
  end

  def test_dictionary_option
    source = %q{
p
 - person
  .name = name
}

    assert_html '<p><div class="name">Joe</div><div class="name">Jack</div></p>', source, :scope => Scope.new, :dictionary => '@hash'
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
      :show_person => true,
      :person => [
        { :name => 'Joe', },
        { :name => 'Jack', }
      ]
    }

    assert_html '<p><div class="name">Joe</div><div class="name">Jack</div>shown</p>', source, :scope => hash
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

    assert_html '<p>No person No person 2</p>', source, :scope => hash
  end

  def test_output_with_content
    source = %{
p = method_with_block do
  block
}
    assert_runtime_error 'Output statements with content are forbidden in logic less mode', source
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

    assert_html '<p><b name="Joe">Person</b><a id="Joe">1</a><span class="Joe"><Person></Person></span><b name="Jack">Person</b><a id="Jack">2</a><span class="Jack"><Person></Person></span></p>', source, :scope => Scope.new, :dictionary => '@hash'
  end

  def test_boolean_attributes
    source = %q{
p
 - person
   input checked=selected = name
}

    assert_html '<p><input checked="checked">Joe</input><input>Jack</input></p>', source, :scope => Scope.new, :dictionary => '@hash'
  end

  def test_sections
    source = %q{
p
 - person
  .name = name
}
    assert_html '<p><div class="name">Joe</div><div class="name">Jack</div></p>', source, :dictionary => 'ViewEnv.new'
  end

  def test_with_array
    source = %q{
ul
 - people_with_locations
  li = name
  li = city
}
    assert_html '<ul><li>Andy</li><li>Atlanta</li><li>Fred</li><li>Melbourne</li><li>Daniel</li><li>Karlsruhe</li></ul>', source, :dictionary => 'ViewEnv.new'
  end

  def test_method
    source = %q{
a href=output_number Link
}
    assert_html '<a href="1337">Link</a>', source, :dictionary => 'ViewEnv.new'
  end

  def test_conditional_parent
    source = %q{
- prev_page
  li.previous
    a href=prev_page Older
- next_page
  li.next
    a href=next_page Newer}
    assert_html'<li class="previous"><a href="prev">Older</a></li><li class="next"><a href="next">Newer</a></li>', source, :scope => {:prev_page => 'prev', :next_page => 'next'}
  end
end
