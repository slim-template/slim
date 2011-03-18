module Slim
  # Tilt template implementation for Slim
  # @api public
  class Template < Temple::Templates::Tilt
    engine Slim::Engine
    register :slim
  end
end
