require File.expand_path('../helper', __FILE__)

class TestSlim < ActionDispatch::IntegrationTest
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

  if ::Rails::VERSION::MAJOR == 3 && ::Rails::VERSION::MINOR >= 1 && Object.const_defined?(:Fiber)
    puts 'Streaming test enabled'
    test "streaming" do
      get "slim/streaming"
      output = "2f\r\n<!DOCTYPE html><html><head><title>Dummy</title>\r\nd\r\n</head><body>\r\n17\r\nHeading set from a view\r\n15\r\n<div class=\"content\">\r\n53\r\n<p>Page content</p><h1><p>Hello Streaming!</p></h1><h2><p>Hello Streaming!</p></h2>\r\n14\r\n</div></body></html>\r\n0\r\n\r\n"
      assert_equal output, @response.body
    end
  else
    puts 'Streaming test disabled'
  end

  test "render integers" do
    get "slim/integers"
    assert_html "<p>1337</p>"
  end

  test "render thread_options" do
    get "slim/thread_options", :attr => 'role'
    assert_html '<p role="empty">Test</p>'
    get "slim/thread_options", :attr => 'id' # Overwriting doesn't work because of caching
    assert_html '<p role="empty">Test</p>'
  end

  test "content_for" do
    get "slim/content_for"
    assert_html "<p>Page content</p><h1><p>Hello Slim!</p></h1><h2><p>Hello Slim!</p></h2>", :heading => 'Heading set from a view'
  end

  test "nested_attributes_form" do
    post "parents", 'parent[name]' => "p1", 'parent[children_attributes][0][name]' => "c1"
    get "parents/1/edit"

    assert_match(%r{<div class="content"><h1>Edit</h1><h2>Form</h2><form accept-charset="UTF-8" action="/parents/1" class="edit_parent" enctype="multipart/form-data" id="edit_parent_1" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="[^"]+" /></div><h1>Parent</h1><input id="parent_name" name="parent\[name\]" size="30" type="text" value="p1" /><h2>Children</h2><ul><li><input id="parent_children_attributes_0_name" name="parent\[children_attributes\]\[0\]\[name\]" size="30" type="text" value="c1" /></li><input id="parent_children_attributes_0_id" name="parent\[children_attributes\]\[0\]\[id\]" type="hidden" value="1" /></ul></form></div>}, @response.body)
  end

  protected

  def assert_html(expected, options = {})
    expected = "<!DOCTYPE html><html><head><title>Dummy</title></head><body>#{options[:heading]}<div class=\"content\">#{expected}</div></body></html>" unless options[:skip_layout]
    assert_equal expected, @response.body
  end
end
