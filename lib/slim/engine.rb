module Slim
  class Engine
    include Precompiler

    # @param template The .slim template to convert
    # @return [Slim::Engine] instance of engine
    def initialize(template)
      @template = template
      precompile
    end


    def render(scope = Object.new, locals = {})
      eval(@precompiled)
    end
  end
end
