module Slim
  # Slim engine which transforms slim code to executable ruby code
  # @api public
  class Engine < Temple::Engine
    # This overwrites some Temple default options or sets default options for Slim specific filters.
    # It is recommended to set the default settings only once in the code and avoid duplication. Only use
    # `define_options` when you have to override some default settings.
    define_options :pretty => false,
                   :sort_attrs => true,
                   :format => :xhtml,
                   :attr_quote => '"',
                   :merge_attrs => {'class' => ' '},
                   :generator => Temple::Generators::ArrayBuffer,
                   :default_tag => 'div'
    define_deprecated_options :attr_delims

    filter :Encoding, :encoding
    filter :RemoveBOM
    use Slim::Parser, :file, :tabsize, :shortcut, :default_tag, :attr_delims, :attr_list_delims, :code_attr_delims
    use Slim::Embedded, :enable_engines, :disable_engines, :pretty
    use Slim::Interpolation
    use Slim::Splat::Filter, :merge_attrs, :attr_quote, :sort_attrs, :default_tag, :hyphen_attrs, :format, :use_html_safe
    use Slim::DoInserter
    use Slim::EndInserter
    use Slim::Controls, :disable_capture
    html :AttributeSorter, :sort_attrs
    html :AttributeMerger, :merge_attrs
    use Slim::CodeAttributes, :merge_attrs
    use(:AttributeRemover) { Temple::HTML::AttributeRemover.new(:remove_empty_attrs => options[:merge_attrs].keys) }
    html :Pretty, :format, :attr_quote, :pretty, :indent, :js_wrapper
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
