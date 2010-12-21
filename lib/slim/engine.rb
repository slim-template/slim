module Slim
  # Slim engine which transforms slim code to executable ruby code
  # @api public
  class Engine < Temple::Engine
    # Allow users to set default options, particularly useful in Rails' environment files.
    # For instance, in config/environments/development.rb you probably want:
    #     # Indent html for pretty debugging
    #     Slim::Engine.set_default_options :pretty => true
    #
    set_default_options :pretty => false,
                        :attr_wrapper => '"',
                        :format => :html5,
                        :id_delimiter => nil,
                        :generator => Temple::Generators::ArrayBuffer,
                        :disable_capture => false,
                        :debug => false

    use Slim::Parser, :file, :tabsize
    use Slim::EmbeddedEngine, :enable_engines, :disable_engines
    use Slim::Interpolation
    use Slim::Sections, :sections, :dictionary, :dictionary_access
    use Slim::EndInserter
    use Slim::Compiler, :disable_capture
    filter :EscapeHTML, :use_html_safe
    use Temple::HTML::Pretty, :format, :attr_wrapper, :id_delimiter, :pretty
    filter :MultiFlattener
    filter :StaticMerger
    filter :DynamicInliner
    filter :Debugger, :debug, :debug_prefix, :debug_pretty
    chain << proc {|options| options[:generator].new }
  end
end
