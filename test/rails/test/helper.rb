# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../../config/environment.rb", __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Run any available migration
ActiveRecord::Migrator.migrate File.expand_path("../../db/migrate/", __FILE__)
