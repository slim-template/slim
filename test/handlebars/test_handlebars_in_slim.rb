require 'helper'
require 'slim/handlebars'

class TestHandlebarsInSlim < TestSlim
  def test_skip_handlebars_partial
    source = <<CODE
{{#view App.MyView}}
  h1 Hello world!
{{/view}}
CODE
    assert_html "{{#view App.MyView}}<h1>Hello world!</h1>{{/view}}", source
  end

  def test_emberjs_action_as_html_attr
    source = <<CODE
button name='test' {{action "loadTweets" target="App.tweetsController"}}  Go!
CODE
    # TODO: check if this is an attribute or text
    assert_html %Q{<button {{action "loadTweets" target="App.tweetsController"}} name="test">Go!</button>}, source
  end

  def test_emberjs_bindattr_as_html_attr
    source = <<CODE
img {{bindAttr src="logoUrl"}} alt="Logo"
CODE
    assert_html '<img {{bindAttr src="logoUrl"}} alt="Logo" />', source
  end

  def test_handlebars_as_text
    source = <<CODE
button {{username}} Go!
CODE
    assert_html '<button>{{username}} Go!</button>', source
  end

  def test_emberjs_in_slim
    source = '{{view App.SearchTextField placeholder="Twitter username" valueBinding="App.tweetsController.username"}}'
    assert_html source, source
  end

  def test_handlebars_comment_in_slim
    source = <<CODE
{{! comment here }}
CODE
    assert_html '{{! comment here }}', source
  end

  def test_handlebars_with_splat_attrs
    source = <<CODE
h1 *hash class=[] {{action "load"}} This is my title
CODE

    assert_html '<h1 {{action "load"}} a="The letter a" b="The letter b">This is my title</h1>', source
  end
end
