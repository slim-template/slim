module Slim
  # Tilt template implementation for Slim
  # @api public
  class Template < Temple::Template
    engine Slim::Engine
    helpers Slim::Helpers
  end

  Tilt.register 'slim', Template
end
