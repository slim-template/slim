require 'helper'

class TestSplatPrefixOption < TestSlim

  def prefixes
    ['*','**','*!','*%','*^','*$']
  end

  def options(prefix)
    { splat_prefix: prefix }
  end

  def test_splat_without_content
    prefixes.each do |prefix|
      source = %Q{
  #{prefix}hash
  p#{prefix}hash
  }

      assert_html '<div a="The letter a" b="The letter b"></div><p a="The letter a" b="The letter b"></p>', source, options(prefix)
    end
  end

  def test_shortcut_splat
    prefixes.each do |prefix|
      source = %Q{
#{prefix}hash This is my title
}

      assert_html '<div a="The letter a" b="The letter b">This is my title</div>', source, options(prefix)
    end
  end

  def test_splat
    prefixes.each do |prefix|
      source = %Q{
h1 #{prefix}hash class=[] This is my title
}

      assert_html '<h1 a="The letter a" b="The letter b">This is my title</h1>', source, options(prefix)
    end
  end

  def test_closed_splat
    prefixes.each do |prefix|
      source = %Q{
#{prefix}hash /
}

      assert_html '<div a="The letter a" b="The letter b" />', source, options(prefix)
    end
  end

  def test_splat_tag_name
    prefixes.each do |prefix|
      source = %Q{
#{prefix}{tag: 'h1', id: 'title'} This is my title
}

      assert_html '<h1 id="title">This is my title</h1>', source, options(prefix)
    end
  end


  def test_splat_empty_tag_name
    prefixes.each do |prefix|
      source = %Q{
#{prefix}{tag: '', id: 'test'} This is my title
}

      assert_html '<div id="test">This is my title</div>', source, options(prefix)
    end
  end

  def test_closed_splat_tag
    prefixes.each do |prefix|
      source = %Q{
#{prefix}hash /
}

      assert_html '<div a="The letter a" b="The letter b" />', source, options(prefix)
    end
  end

  def test_splat_with_id_shortcut
    prefixes.each do |prefix|
      source = %Q{
#myid#{prefix}hash This is my title
}

      assert_html '<div a="The letter a" b="The letter b" id="myid">This is my title</div>', source, options(prefix)
    end
  end

  def test_splat_with_class_shortcut
    prefixes.each do |prefix|
      source = %Q{
.myclass#{prefix}hash This is my title
}

      assert_html '<div a="The letter a" b="The letter b" class="myclass">This is my title</div>', source, options(prefix)
    end
  end

  def test_splat_with_id_and_class_shortcuts
    prefixes.each do |prefix|
      source = %Q{
#myid.myclass#{prefix}hash This is my title
}

      assert_html '<div a="The letter a" b="The letter b" class="myclass" id="myid">This is my title</div>', source, options(prefix)
    end
  end

  def test_splat_with_class_merging
    prefixes.each do |prefix|
      source = %Q{
#myid.myclass #{prefix}{class: [:secondclass, %w(x y z)]} #{prefix}hash This is my title
}

      assert_html '<div a="The letter a" b="The letter b" class="myclass secondclass x y z" id="myid">This is my title</div>', source, options(prefix)
    end
  end

  def test_splat_with_boolean_attribute
    prefixes.each do |prefix|
      source = %Q{
#{prefix}{disabled: true, empty1: false, nonempty: '', empty2: nil} This is my title
}

      assert_html '<div disabled="" nonempty="">This is my title</div>', source, options(prefix)
    end
  end

  def test_splat_merging_with_arrays
    prefixes.each do |prefix|
      source = %Q{
#{prefix}{a: 1, b: 2} #{prefix}[[:c, 3], [:d, 4]] #{prefix}[[:e, 5], [:f, 6]] This is my title
}

      assert_html '<div a="1" b="2" c="3" d="4" e="5" f="6">This is my title</div>', source, options(prefix)
    end
  end

  def test_splat_with_other_attributes
    prefixes.each do |prefix|
      source = %Q{
h1 data-id="123" #{prefix}hash This is my title
}

      assert_html '<h1 a="The letter a" b="The letter b" data-id="123">This is my title</h1>', source, options(prefix)
    end
  end

end
