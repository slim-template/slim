require 'helper'


class TestSlimWrapper < TestSlim
  def setup
    Slim::Sections.set_default_options(:dictionary => 'ViewEnv.new')
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
    assert_html '<p><div class="name">Joe</div><div class="name">Jack</div></p>', source, :sections => true
  end

  def test_with_array
    source = %q{
ul
 - people_with_locations
  li = name
  li = city
}
    assert_html '<ul><li>Andy</li><li>Atlanta</li><li>Fred</li><li>Melbourne</li><li>Daniel</li><li>Karlsruhe</li></ul>', source, :sections => true
  end

  def test_method
    source = %q{
a href=output_number Link
}
    assert_html '<a href="1337">Link</a>', source, :sections => true
  end

end
