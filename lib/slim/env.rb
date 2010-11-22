require File.dirname(__FILE__) + "/string_inquirer"

module Slim
  class << self
    def env
      @_env ||= StringInquirer.new(ENV["SLIM_ENV"] || "release")
    end

    def env=(environment)
      @_env = StringInquirer.new(environment)
    end
  end
end
