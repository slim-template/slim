module Slim
  # Tilt template implementation for Slim
  # @api public
  class Template < Temple::Templates::Tilt
    engine Slim::Engine
    register :slim
  end

  if Kernel.const_defined?(:Rails)
    # Rails template implementation for Slim
    # @api public
    class RailsTemplate < Temple::Templates::Rails
      engine Slim::Engine
      register :slim

      set_default_options :generator => Temple::Generators::RailsOutputBuffer,
                          :disable_capture => true
    end
  end
end
