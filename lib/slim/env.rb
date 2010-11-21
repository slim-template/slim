require 'active_support/string_inquirer'

module Slim
  class << self
    def env
      @_env ||= ActiveSupport::StringInquirer.new(ENV["SLIM_ENV"] || "release")
    end

    def env=(environment)
      @_env = ActiveSupport::StringInquirer.new(environment)
    end
  end
end