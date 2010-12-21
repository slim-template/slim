# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Configure capybara for integration testing
require 'capybara/rails'
Capybara.default_driver   = :rack_test
Capybara.default_selector = :css

# Run any available migration
ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)

class TestSlimRails < ActionController::IntegrationTest
  protected

  def assert_html(expected, options = {})
    expected = "<!DOCTYPE html><html><head><title>Dummy</title></head><body>#{expected}</body></html>" unless options[:skip_layout]
    assert_equal expected, @response.body
  end
end