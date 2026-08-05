require 'helper'
require 'slim/erb_converter'

class TestSlimERBConverter < TestSlim
  def test_converter
        source = %q{
doctype 5
html
  head
    title Hello World!
    /! Meta tags
       with long explanatory
       multiline comment
    meta name="description" content="template language"
    /! Stylesheets
    link href="style.css" media="screen" rel="stylesheet" type="text/css"
    link href="colors.css" media="screen" rel="stylesheet" type="text/css"
    /! Javascripts
    script src="jquery.js"
    script src="jquery.ui.js"
    /[if lt IE 9]
      script src="old-ie1.js"
      script src="old-ie2.js"
    css:
      body { background-color: red; }
  body
    #container
      p Hello
        World!
      p= "dynamic text with\nnewline"
}

    result = %q{
<!DOCTYPE html>
<html>
<head>
<title>Hello World!</title>
<!--Meta tags

with long explanatory

multiline comment-->
<meta content="template language" name="description" />
<!--Stylesheets-->
<link href="style.css" media="screen" rel="stylesheet" type="text/css" />
<link href="colors.css" media="screen" rel="stylesheet" type="text/css" />
<!--Javascripts-->
<script src="jquery.js">
</script><script src="jquery.ui.js">
</script><!--[if lt IE 9]>
<script src="old-ie1.js">
</script><script src="old-ie2.js">
</script><![endif]--><style>
body { background-color: red; }</style>
</head><body>
<div id="container">
<p>Hello

World!</p>
<p><%= ::Temple::Utils.escape_html(("dynamic text with\nnewline")) %>
</p></div></body></html>}

    assert_equal result, Slim::ERBConverter.new.call(source)
  end

  def test_dynamic_attributes
    source = %q{
a href=record_form_path(record)
  ==record.value
}

    result = %q{
<a href="<%= ::Temple::Utils.escape_html((record_form_path(record))) %>">
<%= record.value %>
</a>}

    assert_equal result, Slim::ERBConverter.new.call(source)
  end

  def test_boolean_attributes
    source = %q{
input type="checkbox" checked=is_checked
}

    result = Slim::ERBConverter.new.call(source)
    assert_match(/_slim_codeattributes/, result)
    assert_match(/checked/, result)
  end

  def test_multiple_dynamic_attributes
    source = %q{
a href=user_path(user) title=user.name data-id=user.id Link
}

    result = %q{
<a data-id="<%= ::Temple::Utils.escape_html((user.id)) %>" href="<%= ::Temple::Utils.escape_html((user_path(user))) %>" title="<%= ::Temple::Utils.escape_html((user.name)) %>">Link</a>
}

    assert_equal result, Slim::ERBConverter.new.call(source)
  end

  def test_unescaped_dynamic_attribute
    source = %q{
a href==raw_path
}

    result = %q{
<a href="<%= raw_path %>">
</a>}

    assert_equal result, Slim::ERBConverter.new.call(source)
  end

  def test_mixed_static_and_dynamic_attributes
    source = %q{
img src=image_path(img) alt="Profile picture" width="100"
}

    result = %q{
<img alt="Profile picture" src="<%= ::Temple::Utils.escape_html((image_path(img))) %>" width="100" />
}

    assert_equal result, Slim::ERBConverter.new.call(source)
  end

  def test_various_boolean_attributes
    source = %q{
button disabled=is_disabled Submit
}
    result = Slim::ERBConverter.new.call(source)
    assert_match(/_slim_codeattributes/, result)
    assert_match(/disabled/, result)

    source = %q{
input type="text" readonly=is_readonly
}
    result = Slim::ERBConverter.new.call(source)
    assert_match(/_slim_codeattributes/, result)
    assert_match(/readonly/, result)

    source = %q{
option selected=is_selected Option
}
    result = Slim::ERBConverter.new.call(source)
    assert_match(/_slim_codeattributes/, result)
    assert_match(/selected/, result)

    source = %q{
input type="text" required=is_required
}
    result = Slim::ERBConverter.new.call(source)
    assert_match(/_slim_codeattributes/, result)
    assert_match(/required/, result)

    source = %q{
select multiple=allow_multiple
}
    result = Slim::ERBConverter.new.call(source)
    assert_match(/_slim_codeattributes/, result)
    assert_match(/multiple/, result)

    source = %q{
input type="text" autofocus=should_focus
}
    result = Slim::ERBConverter.new.call(source)
    assert_match(/_slim_codeattributes/, result)
    assert_match(/autofocus/, result)
  end

  def test_boolean_attributes_with_literal_true
    source = %q{
input type="checkbox" checked=true
}

    result = %q{
<input checked="" type="checkbox" />
}

    assert_equal result, Slim::ERBConverter.new.call(source)
  end

  def test_boolean_attributes_with_literal_false
    source = %q{
input type="checkbox" checked=false
}

    result = %q{
<input type="checkbox" />
}

    assert_equal result, Slim::ERBConverter.new.call(source)
  end

  def test_boolean_attributes_with_literal_nil
    source = %q{
input type="checkbox" checked=nil
}

    result = %q{
<input type="checkbox" />
}

    assert_equal result, Slim::ERBConverter.new.call(source)
  end

  def test_class_attribute_merging
    source = %q{
div class="foo" class=dynamic_class
}

    result = Slim::ERBConverter.new.call(source)
    refute_match(/if _slim_codeattributes.*== true/, result)
    assert_match(/class/, result)
  end

  def test_data_attributes
    source = %q{
div data-user-id=user.id data-name=user.name Content
}

    result = %q{
<div data-name="<%= ::Temple::Utils.escape_html((user.name)) %>" data-user-id="<%= ::Temple::Utils.escape_html((user.id)) %>">Content</div>
}

    assert_equal result, Slim::ERBConverter.new.call(source)
  end

  def test_multiple_boolean_attributes
    source = %q{
input type="checkbox" checked=is_checked disabled=is_disabled required=is_required
}

    result = Slim::ERBConverter.new.call(source)
    assert_match(/checked/, result)
    assert_match(/disabled/, result)
    assert_match(/required/, result)
    assert_match(/_slim_codeattributes1/, result)
    assert_match(/_slim_codeattributes2/, result)
    assert_match(/_slim_codeattributes3/, result)
  end

  def test_dynamic_attribute_with_complex_expression
    source = %q{
a href=user_path(user, action: :show, format: :json) Link
}

    result = Slim::ERBConverter.new.call(source)
    assert_match(/user_path\(user, action: :show, format: :json\)/, result)
    refute_match(/if _slim_codeattributes.*== true/, result)
  end

  def test_id_attribute
    source = %q{
div id=dynamic_id Content
}

    result = %q{
<div id="<%= ::Temple::Utils.escape_html((dynamic_id)) %>">Content</div>
}

    assert_equal result, Slim::ERBConverter.new.call(source)
  end
end
