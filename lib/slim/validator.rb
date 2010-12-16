module Slim
  class Validator
    class << self
      def validate!(source)
        Slim::Engine.new.compile(source.to_s)
        true
      rescue Exception => ex
        ex
      end

      def valid?(source)
        validate!(source) === true
      end
    end
  end
end
