require 'slim'

module Slim
  class RailsTemplate < Temple::Templates::Rails
    engine Slim::Engine
    register :slim

    set_default_options :generator => Temple::Generators::RailsOutputBuffer,
                        :disable_capture => true
  end
end
