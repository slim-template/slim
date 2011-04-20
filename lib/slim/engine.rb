module Slim
  # Slim engine which transforms slim code to executable ruby code
  # @api public
  class Engine < Temple::Engine
    # Allow users to set default options, particularly useful in Rails' environment files.
    # For instance, in config/environments/development.rb you probably want:
    #     # Indent html for pretty debugging
    #     Slim::Engine.set_default_options :pretty => true
    #
    # This overwrites some temple default options.
    set_default_options :pretty => false,
                        :attr_wrapper => '"',
                        :format => :html5,
                        :id_delimiter => nil,
                        :generator => Temple::Generators::ArrayBuffer,
                        :buffer => '@_out_buf'

    #
    # Document all supported options with purpose, type etc.
    #
    # Type        | Name               | Default value                 | Purpose
    # --------------------------------------------------------------------------------------------------------------------------------------------
    # String      | :file              | nil                           | Name of parsed file, set automatically by Slim::Template
    # Integer     | :tabsize           | 4                             | Number of whitespaces per tab (used by the parser)
    # String      | :encoding          | utf-8                         | Set encoding of template
    # String list | :enable_engines    | All enabled                   | List of enabled embedded engines (whitelist)
    # String list | :disable_engines   | None disabled                 | List of disabled embedded engines (blacklist)
    # Boolean     | :sections          | false                         | Enable sections mode (logic-less)
    # String      | :dictionary        | "self"                        | Name of dictionary variable in sections mode
    # Symbol      | :dictionary_access | :wrapped                      | Access mode of dictionary variable (:wrapped, :symbol, :string)
    # Boolean     | :disable_capture   | false (true in Rails)         | Disable capturing in blocks (blocks write to the default buffer then)
    # Boolean     | :auto_escape       | true                          | Enable automatic escaping of strings
    # Boolean     | :use_html_safe     | false (true in Rails)         | Use String#html_safe? from ActiveSupport (Works together with :auto_escape)
    # Boolean     | :debug             | false                         | Enable debug outputs (Temple internals)
    # Symbol      | :format            | :html5                        | HTML output format
    # String      | :attr_wrapper      | '"'                           | Character to wrap attributes in html (can be ' or ")
    # String      | :id_delimiter      | '_'                           | Joining character used if multiple html ids are supplied (e.g. #id1#id2)
    # Boolean     | :pretty            | false                         | Pretty html indenting (This is slower!)
    # Class       | :generator         | ArrayBuffer/RailsOutputBuffer | Temple code generator (default generator generates array buffer)
    #
    # It is also possible to set all options supported by the generator (option :generator). The standard generators
    # support the options :buffer and :capture_generator.
    #
    # Options can be set at multiple positions. Slim/Temple uses a inheritance mechanism to allow
    # subclasses to overwrite options of the superclass. The option priorities are as follows:
    #
    # Custom (Options passed by the user) > Slim::Template > Slim::Engine > Parser/Filter/Generator (e.g Slim::Parser, Slim::Compiler)
    #
    # It is also possible to set options for superclasses like Temple::Engine. But this will affect all temple template engines then.
    #
    # Slim::Engine > Temple::Engine
    # Slim::Compiler > Temple::Filter
    #
    # It is recommended to set the default settings only once in the code and avoid duplication. Only use
    # `set_default_options` when you have to override some default settings.
    #
    use Slim::Parser, :file, :tabsize, :encoding
    use Slim::EmbeddedEngine, :enable_engines, :disable_engines, :pretty
    use Slim::Interpolation
    use Slim::Sections, :sections, :dictionary, :dictionary_access
    use Slim::EndInserter
    use Slim::Compiler, :disable_capture, :auto_escape
    filter :EscapeHTML, :use_html_safe
    filter :Debugger, :debug, :debug_prefix => 'After Slim'
    use Temple::HTML::Pretty, :format, :attr_wrapper, :id_delimiter, :pretty
    filter :MultiFlattener
    filter :StaticMerger
    filter :DynamicInliner
    filter :Debugger, :debug, :debug_prefix => 'Optimized code'
    use(:Generator) {|exp| options[:generator].new(options).call(exp) }
  end
end
