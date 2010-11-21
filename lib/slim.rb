# encoding: utf-8

require 'active_support/string_inquirer'
require 'temple'
require 'slim/parser'
require 'slim/filter'
require 'slim/end_inserter'
require 'slim/embedded_engine'
require 'slim/interpolation'
require 'slim/sections'
require 'slim/compiler'
require 'slim/engine'
require 'slim/template'
require 'slim/version'
require 'slim/env'

module Slim
  class << self
    def version
      VERSION
    end

    def env
      @_env ||= ActiveSupport::StringInquirer.new(ENV["SLIM_ENV"] || "release")
    end

    def env=(environment)
      @_env = ActiveSupport::StringInquirer.new(environment)
    end
  end
end
