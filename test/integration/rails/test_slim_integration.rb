require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class TestSlimIntegration < TestSlimRails
  include Capybara

  test "nested_attributes_form" do
    visit "parents/new"
    fill_in "parent_name", :with => "p1"
    fill_in "parent_children_attributes_0_name", :with => "c1"
    click_button "Create Parent"
    click_link "Edit"
    assert_equal true, page.has_content?("input#parent_children_attributes_0_id")
    click_button "Update Parent"
    assert_equal 1, Child.count
  end

  protected

  def assert_html(expected, options = {})
    expected = "<!DOCTYPE html><html><head><title>Dummy</title></head><body>#{expected}</body></html>" unless options[:skip_layout]
    assert_equal expected, @response.body
  end
end
