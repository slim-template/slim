module Slim
  # Tilt template implementation for Slim
  class Template < Tilt::Template
    # Prepare Slim template
    #
    # Called immediately after template data is loaded.
    #
    # @return [void]
    def prepare
      @src = Engine.new(options.merge(:file => eval_file)).compile(data)
    end

    # Process the template and return the result.
    #
    # Template executationis guaranteed to be performed in the scope object with the locals
    # specified and with support for yielding to the block.
    #
    # @param [Object] scope Scope object where the code is evaluated
    # @param [Hash]   locals Local variables
    # @yield Block given to the template code
    # @return [String] Evaluated template
    def evaluate(scope, locals, &block)
      scope.instance_eval { extend Slim::Helpers } if options[:helpers]
      super
    end

    # A string containing the (Ruby) source code for the template.
    #
    # @param [Hash]   locals Local variables
    # @return [String] Compiled template ruby code
    def precompiled_template(locals)
      @src
    end
  end

  Tilt.register 'slim', Template
end
