module Slim
  # Slim engine which transforms slim code to executable ruby code
  # @api public
  class Engine < Temple::Engine
    # Allow users to set options, particularly useful in Rails' environment files.
    # For instance, in config/environments/development.rb you probably want:
    #     # Indent html for pretty debugging
    #     Slim::Engine.options[:pretty] = true
    #
    # @return [Hash] options
    def self.options
      @options ||= {}
    end

    options[:pretty]        = false 
    options[:attr_wrapper]  = '"' 
    options[:format]        = :html5 
    options[:id_delimiter]  = nil

    use Slim::Parser, :file
    use Slim::EmbeddedEngine
    use Slim::Interpolation
    use Slim::Sections, :sections, :dictionary, :dictionary_access
    use Slim::EndInserter
    use Slim::Compiler
    filter :EscapeHTML, :use_html_safe
    use Temple::HTML::Pretty, :format, :attr_wrapper, :id_delimiter, :id_concat, :pretty
    filter :MultiFlattener
    filter :StaticMerger
    filter :DynamicInliner
    generator :ArrayBuffer

    def initialize(options = {})
      super(self.class.options.merge(options))
    end
  end
end
