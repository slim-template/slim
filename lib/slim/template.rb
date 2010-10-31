module Slim
  # Tilt template implementation for Slim
  # @api public
  class Template < Temple::Template
    engine Slim::Engine
  end

  Tilt.register 'slim', Template
end
