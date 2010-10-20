class TestSlimHelpers < TestSlim
  def test_list_of
    string = <<HTML
== list_of([1, 2, 3]) do |i|
  = i
HTML

    expected = "<li>1</li>\n<li>2</li>\n<li>3</li>"

    assert_equal expected, Slim::Engine.new(string, :helpers => true).render(@env)
  end
end
