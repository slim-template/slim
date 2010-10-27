require 'slim'

module ActionView
  module TemplateHandlers
    # Slim handler for Rails 3
    class SlimHandler < TemplateHandler
      include Compilable

      def compile(template)
        Slim::Template.new(:use_html_safe => true){template.source}.prepare
      end
    end
  end

  Template.register_default_template_handler :slim, TemplateHandlers::SlimHandler
end
