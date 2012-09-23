module Slim
  # Slim engine which transforms slim code to executable ruby code
  # @api public
  class Engine < Temple::Engine
    # This overwrites some Temple default options or sets default options for Slim specific filters.
    # It is recommended to set the default settings only once in the code and avoid duplication. Only use
    # `define_options` when you have to override some default settings.
    define_options :pretty => false,
                   :sort_attrs => true,
                   :attr_wrapper => '"',
                   :attr_delimiter => {'class' => ' '},
                   :generator => Temple::Generators::ArrayBuffer,
                   :default_tag => 'div'

    # TODO: Remove these options in 1.4.0
    define_deprecated_options :remove_empty_attrs, :chain

    use Slim::Parser, :file, :tabsize, :encoding, :shortcut, :default_tag, :escape_quoted_attrs
    use Slim::EmbeddedEngine, :enable_engines, :disable_engines, :pretty
    use Slim::Interpolation
    use Slim::EndInserter
    use Slim::ControlStructures, :disable_capture
    use Slim::SplatAttributes, :attr_delimiter, :attr_wrapper, :sort_attrs, :default_tag
    html :AttributeSorter, :sort_attrs
    html :AttributeMerger, :attr_delimiter
    use Slim::BooleanAttributes, :attr_delimiter
    html :Pretty, :format, :attr_wrapper, :pretty, :indent
    filter :Escapable, :use_html_safe, :disable_escape
    filter :ControlFlow
    filter :MultiFlattener
    use :Optimizer do
      (options[:streaming] ? Temple::Filters::StaticMerger : Temple::Filters::DynamicInliner).new
    end
    use :Generator do
      options[:generator].new(options.to_hash.reject {|k,v| !options[:generator].default_options.valid_keys.include?(k) })
    end
  end
end
