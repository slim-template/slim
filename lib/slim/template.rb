module Slim
  class Template < Tilt::Template
    def prepare
      @src = Engine.new(options).compile(data)
    end

    def precompiled_template(locals)
      @src
    end
  end

  Tilt.register 'slim', Template
end

