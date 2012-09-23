require 'helper'
require 'slim/logic_less'

class TestSlimLogicLess < TestSlim
  class Scope
    def initialize
      @hash = {
        :person => [
                    { :name => 'Joe', },
                    { :name => 'Jack', }
                   ]
      }
    end
  end

  def test_symbol_access
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

    assert_html '<p><div class="name">Joe</div><div class="name">Jack</div></p>', source, :scope => hash, :dictionary_access => :symbol
  end

  def test_dictionary_option
    source = %q{
p
 - person
  .name = name
}

    assert_html '<p><div class="name">Joe</div><div class="name">Jack</div></p>', source, :scope => Scope.new, :dictionary => '@hash', :dictionary_access => :symbol
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

    assert_html '<p><div class="name">Joe</div><div class="name">Jack</div></p>', source, :scope => hash, :dictionary_access => :string
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
end
