module Slim
  class Template < Tilt::Template
    def prepare
      @src = Engine.new(options.merge(:file => eval_file)).compile(data)
    end

    def evaluate(scope, locals, &block)
      scope.instance_eval { extend Slim::Helpers } if options[:helpers]
      super
    end

    def precompiled_template(locals)
      @src
    end
  end

  Tilt.register 'slim', Template
end
