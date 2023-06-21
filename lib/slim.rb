# frozen_string_literal: true

require "temple"
require "slim/parser"
require "slim/filter"
require "slim/do_inserter"
require "slim/end_inserter"
require "slim/embedded"
require "slim/interpolation"
require "slim/controls"
require "slim/splat/filter"
require "slim/splat/builder"
require "slim/code_attributes"
require "slim/engine"
require "slim/template"
require "slim/version"
require "slim/railtie" if defined?(Rails::Railtie)
