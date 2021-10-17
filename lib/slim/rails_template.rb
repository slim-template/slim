require "temple"
require "slim/engine"

module Slim
  class RailsTemplate
    class << self
      def options
        @options ||= {
          generator: Temple::Generators::RailsOutputBuffer,
          use_html_safe: true,
          streaming: true
        }
      end

      def set_options(opts)
        options.update(opts)
      end
    end

    def call(template, source = nil)
      source ||= template.source
      options = RailsTemplate.options

      if ActionView::Base.try(:annotate_rendered_view_with_filenames) && template.format == :html
        options[:preamble] = "<!-- BEGIN #{template.short_identifier} -->\n"
        options[:postamble] = "<!-- END #{template.short_identifier} -->\n"
      end

      Slim::Engine.new(options).call(source)
    end

    def supports_streaming?
      RailsTemplate.options[:streaming]
    end
  end

  ActionView::Template.register_template_handler :slim, RailsTemplate.new
end
