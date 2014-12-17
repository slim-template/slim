require 'helper'

class TestSlimHTMLAttributes < TestSlim
  def test_ternary_operation_in_attribute
    source = %q{
p id="#{(false ? 'notshown' : 'shown')}" = output_number
}

    assert_html '<p id="shown">1337</p>', source
  end

  def test_ternary_operation_in_attribute_2
    source = %q{
p id=(false ? 'notshown' : 'shown') = output_number
}

    assert_html '<p id="shown">1337</p>', source
  end

  def test_class_attribute_merging
    source = %{
.alpha class="beta" Test it
}
    assert_html '<div class="alpha beta">Test it</div>', source
  end

  def test_class_attribute_merging_with_nil
    source = %{
.alpha class="beta" class=nil class="gamma" Test it
}
    assert_html '<div class="alpha beta gamma">Test it</div>', source
  end

  def test_class_attribute_merging_with_empty_static
    source = %{
.alpha class="beta" class="" class="gamma" Test it
}
    assert_html '<div class="alpha beta gamma">Test it</div>', source
  end

  def test_id_attribute_merging
    source = %{
#alpha id="beta" Test it
}
    assert_html '<div id="alpha_beta">Test it</div>', source, merge_attrs: {'class' => ' ', 'id' => '_' }
  end

  def test_id_attribute_merging2
    source = %{
#alpha id="beta" Test it
}
    assert_html '<div id="alpha-beta">Test it</div>', source, merge_attrs: {'class' => ' ', 'id' => '-' }
  end

  def test_boolean_attribute_false
    source = %{
- cond=false
option selected=false Text
option selected=cond Text2
}

    assert_html '<option>Text</option><option>Text2</option>', source
  end

  def test_boolean_attribute_true
    source = %{
- cond=true
option selected=true Text
option selected=cond Text2
}

    assert_html '<option selected="">Text</option><option selected="">Text2</option>', source
  end

  def test_boolean_attribute_nil
    source = %{
- cond=nil
option selected=nil Text
option selected=cond Text2
}

    assert_html '<option>Text</option><option>Text2</option>', source
  end

  def test_boolean_attribute_string2
    source = %{
option selected="selected" Text
}

    assert_html '<option selected="selected">Text</option>', source
  end

  def test_boolean_attribute_shortcut
    source = %{
option(class="clazz" selected) Text
option(selected class="clazz") Text
}

    assert_html '<option class="clazz" selected="">Text</option><option class="clazz" selected="">Text</option>', source
  end

  def test_array_attribute_merging
    source = %{
.alpha class="beta" class=[[""], :gamma, nil, :delta, [true, false]]
.alpha class=:beta,:gamma
}

    assert_html '<div class="alpha beta gamma delta true false"></div><div class="alpha beta gamma"></div>', source
  end

  def test_hyphenated_attribute
    source = %{
.alpha data={a: 'alpha', b: 'beta', c_d: 'gamma', c: {e: 'epsilon'}}
}

    assert_html '<div class="alpha" data-a="alpha" data-b="beta" data-c-d="gamma" data-c-e="epsilon"></div>', source
  end

  def test_splat_without_content
    source = %q{
*hash
p*hash
}

    assert_html '<div a="The letter a" b="The letter b"></div><p a="The letter a" b="The letter b"></p>', source
  end

  def test_shortcut_splat
    source = %q{
*hash This is my title
}

    assert_html '<div a="The letter a" b="The letter b">This is my title</div>', source
  end

  def test_splat
    source = %q{
h1 *hash class=[] This is my title
}

    assert_html '<h1 a="The letter a" b="The letter b">This is my title</h1>', source
  end

  def test_closed_splat
    source = %q{
*hash /
}

    assert_html '<div a="The letter a" b="The letter b" />', source
  end

  def test_splat_tag_name
    source = %q{
*{tag: 'h1', id: 'title'} This is my title
}

    assert_html '<h1 id="title">This is my title</h1>', source
  end


  def test_splat_empty_tag_name
    source = %q{
*{tag: '', id: 'test'} This is my title
}

    assert_html '<div id="test">This is my title</div>', source
  end

  def test_closed_splat_tag
    source = %q{
*hash /
}

    assert_html '<div a="The letter a" b="The letter b" />', source
  end

  def test_splat_with_id_shortcut
    source = %q{
#myid*hash This is my title
}

    assert_html '<div a="The letter a" b="The letter b" id="myid">This is my title</div>', source
  end

  def test_splat_with_class_shortcut
    source = %q{
.myclass*hash This is my title
}

    assert_html '<div a="The letter a" b="The letter b" class="myclass">This is my title</div>', source
  end

  def test_splat_with_id_and_class_shortcuts
    source = %q{
#myid.myclass*hash This is my title
}

    assert_html '<div a="The letter a" b="The letter b" class="myclass" id="myid">This is my title</div>', source
  end

  def test_splat_with_class_merging
    source = %q{
#myid.myclass *{class: [:secondclass, %w(x y z)]} *hash This is my title
}

    assert_html '<div a="The letter a" b="The letter b" class="myclass secondclass x y z" id="myid">This is my title</div>', source
  end

  def test_splat_with_boolean_attribute
    source = %q{
*{disabled: true, empty1: false, nonempty: '', empty2: nil} This is my title
}

    assert_html '<div disabled="" nonempty="">This is my title</div>', source
  end

  def test_splat_merging_with_arrays
    source = %q{
*{a: 1, b: 2} *[[:c, 3], [:d, 4]] *[[:e, 5], [:f, 6]] This is my title
}

    assert_html '<div a="1" b="2" c="3" d="4" e="5" f="6">This is my title</div>', source
  end

  def test_splat_with_other_attributes
    source = %q{
h1 data-id="123" *hash This is my title
}

    assert_html '<h1 a="The letter a" b="The letter b" data-id="123">This is my title</h1>', source
  end

  def test_attribute_merging
    source = %q{
a class=true class=false
a class=false *{class:true}
a class=true
a class=false
}

    assert_html '<a class="true false"></a><a class="false true"></a><a class="true"></a><a class="false"></a>', source
  end

  def test_static_empty_attribute
    source = %q{
p(id="marvin" name="" class="" data-info="Illudium Q-36")= output_number
}

    assert_html '<p data-info="Illudium Q-36" id="marvin" name="">1337</p>', source
  end

  def test_dynamic_empty_attribute
    source = %q{
p(id="marvin" class=nil nonempty=("".to_s) data-info="Illudium Q-36")= output_number
}

    assert_html '<p data-info="Illudium Q-36" id="marvin" nonempty="">1337</p>', source
  end

  def test_weird_attribute
    source = %q{
p
  img(src='img.png' whatsthis?!)
  img src='img.png' whatsthis?!="wtf"
}
    assert_html '<p><img src="img.png" whatsthis?!="" /><img src="img.png" whatsthis?!="wtf" /></p>', source
  end
end
