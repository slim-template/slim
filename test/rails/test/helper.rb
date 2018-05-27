# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../../config/environment.rb", __FILE__)
require "rails/test_help"
require "nokogiri"

require 'rails-controller-testing'
Rails::Controller::Testing.install

Rails.backtrace_cleaner.remove_silencers!

class ActionDispatch::IntegrationTest

protected

  def assert_xpath(xpath, message="Unable to find '#{xpath}' in response body.")
    assert_response :success, "Response type is not :success (code 200..299)."

    body = @response.body
    assert !body.empty?, "No response body found."

    doc = Nokogiri::HTML(body) rescue nil
    assert_not_nil doc, "Cannot parse response body."

    assert doc.xpath(xpath).size >= 1, message
  end

  def assert_html(expected, options = {})
    expected = "<!DOCTYPE html><html><head><title>Dummy</title></head><body>#{options[:heading]}<div class=\"content\">#{expected}</div></body></html>" unless options[:skip_layout]
    assert_equal expected, @response.body
  end

end
