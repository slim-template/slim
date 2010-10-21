require 'helper'

class TestSlimHelpers < TestSlim
  def test_list_of
    source = %q{
== list_of([1, 2, 3]) do |i|
  = i
}

    assert_html "<li>1</li>\n<li>2</li>\n<li>3</li>", source, :helpers => true
  end
end
