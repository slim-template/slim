require 'helper'

class TestSlimLogicLess < TestSlim
  def setup
    Slim::Sections.set_default_options(:dictionary_access => :symbol)
  end

  def teardown
    Slim::Sections.set_default_options(:dictionary => 'self')
  end

  def test_sections
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

    assert_html '<p><div class="name">Joe</div><div class="name">Jack</div></p>', source, :scope => hash, :sections => true
  end

  def test_sections_string_access
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

    assert_html '<p><div class="name">Joe</div><div class="name">Jack</div></p>', source, :scope => hash, :sections => true, :dictionary_access => :string
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

    assert_html '<p><div class="name">Joe</div><div class="name">Jack</div>shown</p>', source, :scope => hash, :sections => true
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

    assert_html '<p>No person No person 2</p>', source, :scope => hash, :sections => true
  end

  def test_output_with_content
    source = %{
p = method_with_block do
  block
}
    assert_runtime_error 'Output statements with content are forbidden in sections mode', source, :sections => true
  end
end
