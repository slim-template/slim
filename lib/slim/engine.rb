module Slim
  # Slim engine which transforms slim code to executable ruby code
  # @api public
  class Engine < Temple::Engine
    # This overwrites some Temple default options or sets default options for Slim specific filters.
    # It is recommended to set the default settings only once in the code and avoid duplication. Only use
    # `define_options` when you have to override some default settings.
    define_options :attr_quote,
                   :merge_attrs,
                   :pretty => false,
                   :sort_attrs => true,
                   :generator => Temple::Generators::ArrayBuffer,
                   :default_tag => 'div',
                   :attr_quote => '"',
                   :merge_attrs => {'class' => ' '},
                   :escape_quoted_attrs => false

    # Removed in 2.0
    define_deprecated_options :remove_empty_attrs,
                              :chain,
                              :escape_quoted_attrs,
                              :attr_wrapper,
                              :attr_delimiter

    def initialize(opts = {})
      super
      deprecated = {}
      deprecated[:merge_attrs] = options[:attr_delimiter] if options.include? :attr_delimiter
      deprecated[:attr_quote] = options[:attr_wrapper] if options.include? :attr_wrapper
      @options = Temple::ImmutableHash.new(deprecated, @options) unless deprecated.empty?
    end

    use Slim::Parser, :file, :tabsize, :encoding, :shortcut, :default_tag, :escape_quoted_attrs
    use Slim::Embedded, :enable_engines, :disable_engines, :pretty
    use Slim::Interpolation
    use Slim::EndInserter
    use Slim::Controls, :disable_capture
    use Slim::SplatAttributes, :merge_attrs, :attr_quote, :sort_attrs, :default_tag
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
