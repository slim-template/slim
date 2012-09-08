require 'helper'
require 'slim/logic_less'

class TestSlimWrapper < TestSlim
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

end
