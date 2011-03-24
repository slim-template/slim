module Slim
  # Tilt template implementation for Slim
  # @api public
  Template = Temple::Templates::Tilt(Slim::Engine, :register_as => :slim)

  if Kernel.const_defined?(:Rails)
    # Rails template implementation for Slim
    # @api public
    RailsTemplate = Temple::Templates::Rails(Slim::Engine, :register_as => :slim)

    # Use rails-specific generator. This is necessary
    # to support block capturing. Disable the internal slim capturing.
    # Rails takes care of the capturing by itself.
    RailsTemplate.set_default_options :generator => Temple::Generators::RailsOutputBuffer,
                                      :disable_capture => true
  end
end
