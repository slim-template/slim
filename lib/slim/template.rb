module Slim
  # Tilt template implementation for Slim
  # @api public
  class Template < Temple::Templates::Tilt
    # Use the Slim::Engine for this template
    engine Slim::Engine

    # Register this template for *.slim files in Tilt
    register :slim
  end

  if Kernel.const_defined?(:Rails)
    # Rails template implementation for Slim
    # @api public
    class RailsTemplate < Temple::Templates::Rails
      # Use the Slim::Engine for this template
      engine Slim::Engine

      # Register this template for *.slim files in Rails
      register :slim

      # Use rails-specific generator. This is necessary
      # to support block capturing. Disable the internal slim capturing.
      # Rails takes care of the capturing by itself.
      set_default_options :generator => Temple::Generators::RailsOutputBuffer,
                          :disable_capture => true
    end
  end
end
