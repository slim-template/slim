require 'slim'

module Slim
  # Implements a safe string buffer.
  class SafeBufferGenerator < Temple::Generators::StringBuffer
    def preamble; "#{buffer} = ActiveSupport::SafeBuffer.new" end

    def concat(str)
      "#{buffer}.safe_concat((#{str}))"
    end
  end

  # Should be set automatically by Temple (detects html_safe? method)
  Temple::Filters::EscapeHTML.default_options[:use_html_safe] = true

  # Make return values of captured blocks html safe
  Temple::Generator.default_options[:capture_generator] = SafeBufferGenerator
end

module ActionView
  module TemplateHandlers
    raise "Slim supports only Rails 3.x and greater, your Rails version is #{Rails::VERSION::STRING}" if Rails::VERSION::MAJOR < 3

    if Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR < 1
      # Slim handler for Rails 3.0
      class SlimHandler < TemplateHandler
        include Compilable

        def compile(template)
          Slim::Engine.new.compile(template.source)
        end
      end
    else
      # Slim handler for Rails 3.1 and greater
      class SlimHandler
        def self.call(template)
          Slim::Engine.new.compile(template.source)
        end
      end
    end
  end

  Template.register_default_template_handler :slim, TemplateHandlers::SlimHandler
end
