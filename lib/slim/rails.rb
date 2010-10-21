require 'slim'

module ActionView
  module TemplateHandlers
    class SlimHandler < TemplateHandler
      include Compilable

      def compile(template)
        return Slim::Engine.new(template.source).prepare
      end
    end
  end

  Template.register_default_template_handler :slim, TemplateHandlers::SlimHandler
end
