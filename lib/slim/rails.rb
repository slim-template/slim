require 'slim'

Slim::Engine.default_options[:generator] = Temple::Generators::RailsOutputBuffer
Slim::Engine.default_options[:disable_capture] = true

module ActionView
  module TemplateHandlers
    if Rails::VERSION::MAJOR < 3
      raise "Slim supports only Rails 3.x and greater, your Rails version is #{Rails::VERSION::STRING}"
    end

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

  Template.register_template_handler :slim, TemplateHandlers::SlimHandler
end
