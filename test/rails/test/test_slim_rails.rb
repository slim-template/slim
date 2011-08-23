require File.expand_path('../helper', __FILE__)

class TestSlimRails < ActionController::IntegrationTest
  test "normal view" do
    get "slim/normal"
    assert_response :success
    assert_template ["slim/normal", "layouts/application"]
    assert_html "<h1>Hello Slim!</h1>"
  end

  test "normal erb view" do
    get "slim/erb"
    assert_html "<h1>Hello Erb!</h1>"
  end

  test "view without a layout" do
    get "slim/no_layout"
    assert_template "slim/no_layout"
    assert_html "<h1>Hello Slim without a layout!</h1>", :skip_layout => true
  end

  test "view with variables" do
    get "slim/variables"
    assert_html "<h1>Hello Slim with variables!</h1>"
  end

  test "partial view" do
    get "slim/partial"
    assert_html "<h1>Hello Slim!</h1><p>With a partial!</p>"
  end

  test "render integers" do
    get "slim/integers"
    assert_html "<p>1337</p>"
  end

  test "render nil" do
    get "slim/nil"
    assert_html "<p></p>"
  end

  test "content_for" do
    get "slim/content_for"
    assert_html "Heading set from a view<p>Page content</p><h1><p>Hello Slim!</p></h1><h2><p>Hello Slim!</p></h2>"
  end

  test "nested_attributes_form" do
    post "parents", 'parent[name]' => "p1", 'parent[children_attributes][0][name]' => "c1"
    get "parents/1/edit"

    assert_html '<form accept-charset="UTF-8" action="/parents/1" class="edit_parent" enctype="multipart/form-data" id="edit_parent_1" method="post">'+
      '<div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="put" />'+
      '</div><h1>Parent</h1><input id="parent_name" name="parent[name]" size="30" type="text" value="p1" />'+
      '<h2>Children</h2>'+
      '<ul><li><input id="parent_children_attributes_0_name" name="parent[children_attributes][0][name]" size="30" type="text" value="c1" /></li>'+
      '<input id="parent_children_attributes_0_id" name="parent[children_attributes][0][id]" type="hidden" value="1" /></ul>'+
      '</form>'
  end

  protected

  def assert_html(expected, options = {})
    expected = "<!DOCTYPE html><html><head><title>Dummy</title></head><body>#{expected}</body></html>" unless options[:skip_layout]
    assert_equal expected, @response.body
  end
end
