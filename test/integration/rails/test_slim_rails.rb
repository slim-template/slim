require File.expand_path(File.dirname(__FILE__) + '/test_helper')

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
    assert_html "Heading set from a view<h1>Hello Slim!</h1><h2>Hello Slim!</h2>"
  end

  test "nested_attributes_form" do
    post "parents", 'parent[name]' => "p1", 'parent[children_attributes][0][name]' => "c1"
    get "parents/1/edit"
    assert_has_html '<input id="parent_children_attributes_0_id" name="parent[children_attributes][0][id]" type="hidden" value="1" />'
  end

  protected

  def assert_html(expected, options = {})
    expected = "<!DOCTYPE html><html><head><title>Dummy</title></head><body>#{expected}</body></html>" unless options[:skip_layout]
    assert_equal expected, @response.body
  end

  def assert_has_html(expected)
    assert_match expected, @response.body
  end
end
