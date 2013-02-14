# -*- coding: utf-8 -*-
require 'helper'

class TestSlimSmartText < TestSlim
  def setup
    Slim::Engine.set_default_options :smart_text => true
  end

  def teardown
    Slim::Engine.set_default_options :smart_text => false
  end

  def test_explicit_smart_text_recognition
    source = %q{
>
  a
>
  b
  
>
 
  c
>

  d
  
> e
f
> g
  h
i
}

    result = %q{a
b
c
d
e
<f></f>
g
h
<i></i>}

    assert_html result, source
  end

  def test_implicit_smart_text_recognition
    source = %q{
p
  A
p
  B
  
p
 
  C
p

  D
  
p E
F
p G
  H
I
}

    result = %q{<p>A</p><p>B</p><p>C</p><p>D</p><p>E</p>
F
<p>G
H</p>
I}

    assert_html result, source
  end

  def test_multi_line_smart_text
    source = %q{
p
  First line.
  Second line.
  Third line
   with a continuation
   and one more.
  Fourth line.
}

    result = %q{<p>First line.
Second line.
Third line
with a continuation
and one more.
Fourth line.</p>}

    assert_html result, source
  end

  def test_smart_text_escaping
    source = %q{
p Not escaped <&>.
| Not escaped <&>.
p
  Escaped <&>.
  > Escaped <&>.
  Protected &amp; &lt; &gt; &copy; &Aacute;.
  Protected &#0129; &#x00ff;.
  Escaped &#xx; &#1f; &;.
}

    result = %q{<p>Not escaped <&>.</p>Not escaped <&>.<p>Escaped &lt;&amp;&gt;.
Escaped &lt;&amp;&gt;.
Protected &amp; &lt; &gt; &copy; &Aacute;.
Protected &#0129; &#x00ff;.
Escaped &amp;#xx; &amp;#1f; &amp;;.</p>}

    assert_html result, source
  end

  def test_smart_text_disabled_escaping
    Slim::Engine.with_options( :smart_text_escaping => false ) do
      source = %q{
p Not escaped <&>.
| Not escaped <&>.
p
  Not escaped <&>.
  > Not escaped <&>.
  Not escaped &amp; &lt; &gt; &copy; &Aacute;.
  Not escaped &#0129; &#x00ff;.
  Not escaped &#xx; &#1f; &;.
}

    result = %q{<p>Not escaped <&>.</p>Not escaped <&>.<p>Not escaped <&>.
Not escaped <&>.
Not escaped &amp; &lt; &gt; &copy; &Aacute;.
Not escaped &#0129; &#x00ff;.
Not escaped &#xx; &#1f; &;.</p>}

      assert_html result, source
    end
  end

  def test_smart_text_in_tag_escaping
    Slim::Engine.with_options( :smart_text_in_tags => true ) do
      source = %q{
p Escaped <&>.
  Protected &amp; &lt; &gt; &copy; &Aacute;.
  Protected &#0129; &#x00ff;.
  Escaped &#xx; &#1f; &;.
}

      result = %q{<p>Escaped &lt;&amp;&gt;.
Protected &amp; &lt; &gt; &copy; &Aacute;.
Protected &#0129; &#x00ff;.
Escaped &amp;#xx; &amp;#1f; &amp;;.</p>}

      assert_html result, source
    end
  end

  def test_smart_text_mixed_with_tags
    source = %q{
p
  Text
  br
  >is
  strong really
  > recognized.

  More
  b text
  .
  
  And 
  i more
  ...
  
  span Really
  ?!?
  
  .bold Really
  !!!
  
  #id
    #{'Good'}
  !
}

    result = %q{<p>Text
<br />
is
<strong>really</strong>
recognized.
More
<b>text</b>.
And 
<i>more</i>...
<span>Really</span>?!?
<div class="bold">Really</div>!!!
<div id="id">Good</div>!</p>}

    assert_html result, source
  end

  def test_smart_text_mixed_with_links
    source = %q{
p
  Text with
  a href="#1" link
  .

  Text with
  a href="#2" another
              link
  > to somewhere else.

  a href="#3"
    This link
  > goes
    elsewhere.
    
  See (
  a href="#4" link
  )?
}

    result = %q{<p>Text with
<a href="#1">link</a>.
Text with
<a href="#2">another
link</a>
to somewhere else.
<a href="#3">This link</a>
goes
elsewhere.
See (<a href="#4">link</a>)?</p>}

    assert_html result, source
  end

  def test_smart_text_mixed_with_code
    source = %q{
p
  Try a list
  ul
    - 2.times do |i|
      li
        Item: #{i}
  > which stops
  b here
  . Right?
}

    result = %q{<p>Try a list
<ul><li>Item: 0</li><li>Item: 1</li></ul>
which stops
<b>here</b>. Right?</p>}

    assert_html result, source
  end
  
  # Without unicode support, we can't distinguish uppercase and lowercase
  # unicode characters reliably. So we only test the basic stuff in extended mode.

  def test_unicode_extended_smart_text
    
    Slim::Engine.with_options( :smart_text_extended => true ) do
  
      source = %q{
p
  是
  čip
  Čip
  Žůžo
  šíp
}

      result = %q{<p>是
čip
Čip
Žůžo
šíp</p>}

      assert_html result, source
    end
  end

  if ''.respond_to?(:encoding)

    def test_unicode_smart_text

      Slim::Engine.with_options( :smart_text_extended => false ) do

        source = %q{
p
  是
  čip
  Čip
  Žůžo
  šíp
  .řek
    .
}

        result = %q{<p><是></是><čip></čip>
Čip
Žůžo
<šíp></šíp><div class="řek">.</div></p>}

        assert_html result, source
      end
    end

    def test_unicode_extended_smart_text
    
      Slim::Engine.with_options( :smart_text_extended => true ) do
  
        source = %q{
p
  是
  čip
  Čip
  Žůžo
  šíp
  .řek
    .
}

        result = %q{<p>是
čip
Čip
Žůžo
šíp
<div class="řek">.</div></p>}

        assert_html result, source
      end
    end
  end
end
