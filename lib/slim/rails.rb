require 'slim'

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
        def call(template)
          Slim::Engine.new.compile(template.source)
        end
      end
    end
  end

  Template.register_default_template_handler :slim, TemplateHandlers::SlimHandler
end
