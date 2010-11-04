require 'slim'

module ActionView
  module TemplateHandlers
    # Slim handler for Rails 3
    class SlimHandler < TemplateHandler
      include Compilable

      def compile(template)
        Slim::Engine.new.compile(template.source)
      end
    end
  end

  Template.register_default_template_handler :slim, TemplateHandlers::SlimHandler
end
