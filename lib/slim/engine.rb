module Slim
  # Slim engine which transforms slim code to executable ruby code
  # @api public
  class Engine < Temple::Engine
    use Slim::Parser, :file
    use Slim::EndInserter
    use Slim::EmbeddedEngine
    use Slim::Compiler, :use_html_safe
    #use Slim::Debugger
    use Temple::HTML::Fast, :format, :attr_wrapper => '"', :format => :html5
    filter :MultiFlattener
    filter :StaticMerger
    filter :DynamicInliner
    generator :ArrayBuffer
  end
end
