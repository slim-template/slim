require 'helper'
require 'slim/translator'

class TestSlimTranslator < TestSlim
  def setup
    super
    Slim::Engine.set_options tr: true, tr_fn: 'TestSlimTranslator.tr'
  end

  def self.tr(s)
    s.upcase
  end

  def self.tr_reverse(s)
    s.reverse.gsub(/(\d+)%/, '%\1')
  end

  def test_no_translation_of_embedded
    source = %q{
markdown:
  #Header
  Hello from #{"Markdown!"}

  #{1+2}

  * one
  * two
}

    case Tilt['md'].name.downcase
    when /redcarpet/
      assert_html "<h1>Header</h1>\n\n<p>Hello from Markdown!</p>\n\n<p>3</p>\n\n<ul>\n<li>one</li>\n<li>two</li>\n</ul>\n", source, tr_mode: :dynamic
      assert_html "<h1>Header</h1>\n\n<p>Hello from Markdown!</p>\n\n<p>3</p>\n\n<ul>\n<li>one</li>\n<li>two</li>\n</ul>\n", source, tr_mode: :static
    when /rdiscount/
      assert_html "<h1>Header</h1>\n\n<p>Hello from Markdown!</p>\n\n<p>3</p>\n\n<ul>\n<li>one</li>\n<li>two</li>\n</ul>\n\n", source, tr_mode: :dynamic
      assert_html "<h1>Header</h1>\n\n<p>Hello from Markdown!</p>\n\n<p>3</p>\n\n<ul>\n<li>one</li>\n<li>two</li>\n</ul>\n\n", source, tr_mode: :static
    when /kramdown/
      assert_html "<h1 id=\"header\">Header</h1>\n<p>Hello from Markdown!</p>\n\n<p>3</p>\n\n<ul>\n  <li>one</li>\n  <li>two</li>\n</ul>\n", source, tr_mode: :dynamic
      assert_html "<h1 id=\"header\">Header</h1>\n<p>Hello from Markdown!</p>\n\n<p>3</p>\n\n<ul>\n  <li>one</li>\n  <li>two</li>\n</ul>\n", source, tr_mode: :static
    else
      raise "Missing test for #{Tilt['md']}"
    end
  end

  def test_no_translation_of_attrs
    source = %q{
' this is
  a link to
a href="link" page
}

    assert_html "THIS IS\nA LINK TO <a href=\"link\">PAGE</a>", source, tr_mode: :dynamic
    assert_html "THIS IS\nA LINK TO <a href=\"link\">PAGE</a>", source, tr_mode: :static
  end

  def test_translation_and_interpolation
    source = %q{
p translate #{hello_world} this
  second line
  third #{1+2} line
}

    assert_html "<p>translate Hello World from @env this\nsecond line\nthird 3 line</p>", source, tr: false
    assert_html "<p>TRANSLATE Hello World from @env THIS\nSECOND LINE\nTHIRD 3 LINE</p>", source, tr_mode: :dynamic
    assert_html "<p>TRANSLATE Hello World from @env THIS\nSECOND LINE\nTHIRD 3 LINE</p>", source, tr_mode: :static
  end

  def test_translation_reverse
    source = %q{
' alpha #{1} beta #{2} gamma #{3}
}

    assert_html "3 ammag 2 ateb 1 ahpla ", source, tr_mode: :dynamic, tr_fn: 'TestSlimTranslator.tr_reverse'
    assert_html "3 ammag 2 ateb 1 ahpla ", source, tr_mode: :static, tr_fn: 'TestSlimTranslator.tr_reverse'
  end
end
