module Slim
  class Wrapper
    attr_reader :value, :parent

    def initialize(value, parent = nil)
      @value, @parent = value, parent
    end

    def method_missing(name, *args, &block)
      if value.respond_to?(name)
        wrap value.send(name, *args, &block)
      elsif value.respond_to?(:has_key?) && value.has_key?(name.to_sym)
        wrap value[name]
      elsif value.instance_variable_defined?("@#{name}")
        wrap value.instance_variable_get("@#{name}")
      elsif parent
        parent.send(name, *args, &block)
      else
        raise NoMethodError.new "undefined method #{name}"
      end
    end
    
    # Empty objects must appear empty for inverted sections
    def empty?
      value.respond_to?(:empty) && value.empty?
    end

    private 

    def wrap(response)
      # Primitives are not wrapped
      if [String, Numeric, TrueClass, FalseClass, NilClass].any? {|primitive| primitive === response }
        response
        # Enumerables are mapped with wrapped values (except Hash-like objects)
      elsif !response.respond_to?(:has_key?) && response.respond_to?(:map)
        response.map {|v| wrap(v) }
      else
        Wrapper.new(response, self)
      end
    end
  end
end
