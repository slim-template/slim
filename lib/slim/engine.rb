module Slim
  # Slim engine which transforms slim code to executable ruby code
  # @api public
  class Engine < Temple::Engine
    use Slim::Parser, :file
    filter :Debugger, :debug, :prefix => 'before end insertion'
    use Slim::EndInserter
    filter :Debugger, :debug, :prefix => 'after end insertion'
    use Slim::EmbeddedEngine
    use Slim::Compiler
    filter :Debugger, :debug, :prefix => 'after compilation'
    filter :EscapeHTML, :use_html_safe
    use Temple::HTML::Pretty, :format, :attr_wrapper, :id_delimiter, :id_concat, :pretty,
                              :pretty => false, :attr_wrapper => '"', :format => :html5, :id_delimiter => nil
    filter :Debugger, :debug, :prefix => 'after html'
    filter :MultiFlattener
    filter :StaticMerger
    filter :DynamicInliner
    generator :ArrayBuffer
  end
end
