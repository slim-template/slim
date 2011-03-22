module Slim
  module Validator
    class << self
      def validate!(source)
        Slim::Engine.new.call(source.to_s)
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
