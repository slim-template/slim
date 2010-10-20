module Slim
  class Engine < Temple::Engine
    use Slim::Parser
    use Slim::EndInserter
    use Slim::Compiler, :use_html_safe
    #use Slim::Debugger
    use Temple::HTML::Fast, :format, :attr_wrapper => '"', :format => :html5
    filter :MultiFlattener
    filter :StaticMerger
    filter :DynamicInliner
    generator :ArrayBuffer

    def self.new(*args)
      if args.first.respond_to?(:each_line)
        Template.new(Hash === args.last ? args.last : {}) { args.first }
      else
        super
      end
    end
  end
end
