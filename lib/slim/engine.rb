module Slim
  # Slim engine which transforms slim code to executable ruby code
  # @api public
  class Engine < Temple::Engine
    # This overwrites some Temple default options or sets default options for Slim specific filters.
    # It is recommended to set the default settings only once in the code and avoid duplication. Only use
    # `set_default_options` when you have to override some default settings.
    set_default_options :pretty => false,
                        :sort_attrs => true,
                        :attr_wrapper => '"',
                        :attr_delimiter => {'class' => ' '},
                        :remove_empty_attrs => true,
                        :generator => Temple::Generators::ArrayBuffer,
                        :default_tag => 'div'

    use Slim::Parser, :file, :tabsize, :encoding, :shortcut, :default_tag
    use Slim::EmbeddedEngine, :enable_engines, :disable_engines, :pretty
    use Slim::Interpolation
    use Slim::EndInserter
    use Slim::Compiler, :disable_capture, :attr_delimiter, :attr_wrapper, :sort_attrs, :remove_empty_attrs, :default_tag
    html :AttributeMerger, :attr_delimiter
    html :AttributeSorter, :sort_attrs
    html :AttributeRemover, :remove_empty_attrs
    html :Pretty, :format, :attr_wrapper, :pretty, :indent
    filter :Escapable, :use_html_safe, :disable_escape
    filter :ControlFlow
    filter :MultiFlattener
    use(:Optimizer) { (options[:streaming] ? Temple::Filters::StaticMerger :
                       Temple::Filters::DynamicInliner).new }
    use(:Generator) { options[:generator].new(options) }
  end
end
