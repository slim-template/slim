require 'slim'

Slim::Engine.default_options[:generator] = Temple::Generators::RailsOutputBuffer

module ActionView
  module TemplateHandlers
    raise "Slim supports only Rails 3.x and greater, your Rails version is #{Rails::VERSION::STRING}" if Rails::VERSION::MAJOR < 3

    if Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR < 1
      # Slim handler for Rails 3.0
      class SlimHandler < TemplateHandler
        include Compilable

        def compile(template)
          if Slim::Engine.default_options[:sections]
            Slim::Sections.set_default_options(:dictionary => 'Slim::Wrapper.new(self)')
          end

          Slim::Engine.new.compile(template.source)
        end
      end
    else
      # Slim handler for Rails 3.1 and greater
      class SlimHandler
        def self.call(template)
          if Slim::Engine.default_options[:sections]
            Slim::Sections.set_default_options(:dictionary => 'Slim::Wrapper.new(self)')
          end
          Slim::Engine.new.compile(template.source)
        end
      end
    end
  end

  Template.register_default_template_handler :slim, TemplateHandlers::SlimHandler
end
