require 'helper'

class TestSlimHelpers < TestSlim
  class HtmlSafeString < String
    def html_safe?
      true
    end
  end

  def test_list_of
    source = %q{
== list_of([1, 2, 3]) do |i|
  = i
}

    assert_html "<li>1</li>\n<li>2</li>\n<li>3</li>", source, :helpers => true
  end

  def test_list_of_with_html_safe
    Object.send(:define_method, :html_safe?) { false }
    String.send(:define_method, :html_safe) { HtmlSafeString.new(self) }

    source = %q{
= list_of([1, 2, 3]) do |i|
  = i
}

    html = Slim::Template.new(:helpers => true, :use_html_safe => true) { source }.render(@env)
  end
end
