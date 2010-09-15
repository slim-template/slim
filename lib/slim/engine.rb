module Slim
  class Engine
    include Compiler

    attr_reader :compiled

    # @param template The .slim template to convert
    # @return [Slim::Engine] instance of engine
    def initialize(template)
      @template = template
      compile
    end

    def render(scope = Object.new, locals = {})
      scope.instance_eval(compiled)
    end
  end
end
