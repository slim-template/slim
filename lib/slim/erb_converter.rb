require 'slim'

module Slim
  class ERBConverter < Engine
    replace :Optimizer, Temple::Filters::CodeMerger
    replace :Generator, Temple::Generators::ERB
  end
end
