require 'slim'

module Slim
  # Slim to ERB converter
  #
  # @example Conversion
  #   Slim::ERBConverter.new(options).call(slim_code) # outputs erb_code
  #
  # @api public
  class ERBConverter < Engine
    remove :StaticMerger
    replace :StaticFreezer, Temple::Filters::CodeMerger
    replace :Generator, Temple::Generators::ERB
  end
end
