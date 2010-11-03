module Slim
  # Slim engine which transforms slim code to executable ruby code
  # @api public
  class Engine < Temple::Engine
    use Slim::Parser, :file
    use Slim::EmbeddedEngine
    use Slim::Interpolation
    use Slim::Sections, :sections, :dictionary, :dictionary_access
    use Slim::EndInserter
    use Slim::Compiler
    filter :EscapeHTML, :use_html_safe
    use Temple::HTML::Pretty, :format, :attr_wrapper, :id_delimiter, :id_concat, :pretty,
                              :pretty => false, :attr_wrapper => '"', :format => :html5, :id_delimiter => nil
    filter :MultiFlattener
    filter :StaticMerger
    filter :DynamicInliner
    generator :ArrayBuffer
  end
end
