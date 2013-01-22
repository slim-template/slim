module Slim
  # Slim engine which transforms slim code to executable ruby code
  # @api public
  class Engine < Temple::Engine
    # This overwrites some Temple default options or sets default options for Slim specific filters.
    # It is recommended to set the default settings only once in the code and avoid duplication. Only use
    # `define_options` when you have to override some default settings.
    define_options :pretty => false,
                   :sort_attrs => true,
                   :attr_quote => '"',
                   :merge_attrs => {'class' => ' '},
                   :generator => Temple::Generators::ArrayBuffer,
                   :default_tag => 'div'

    use Slim::Parser, :file, :tabsize, :encoding, :shortcut, :default_tag,
        :smart_text, :smart_text_extended, :smart_text_chars, :smart_text_in_tags
    use Slim::Smart::Filter, :smart_text_end_chars, :smart_text_begin_chars
    use Slim::Embedded, :enable_engines, :disable_engines, :pretty
    use Slim::Interpolation
    use Slim::Smart::Escaper
    use Slim::Splat::Filter, :merge_attrs, :attr_quote, :sort_attrs, :default_tag, :hyphen_attrs
    use Slim::EndInserter
    use Slim::Controls, :disable_capture
    html :AttributeSorter, :sort_attrs
    html :AttributeMerger, :merge_attrs
    use Slim::CodeAttributes, :merge_attrs
    use(:AttributeRemover) { Temple::HTML::AttributeRemover.new(:remove_empty_attrs => options[:merge_attrs].keys) }
    html :Pretty, :format, :attr_quote, :pretty, :indent
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
