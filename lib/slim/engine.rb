module Slim
  class Engine < Temple::Engine
    use Slim::Parser
    use Slim::EndInserter
    use Slim::Compiler
    use Temple::HTML::Fast, :format, :attr_wrapper => '"'
    filter :MultiFlattener
    filter :StaticMerger
    filter :DynamicInliner
    generator :ArrayBuffer

    def self.new(options = {})
      if options.respond_to?(:each_line)
        Template.new { options }
      else
        super
      end
    end
  end
end

