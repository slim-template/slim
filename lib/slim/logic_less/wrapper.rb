module Slim
  class LogicLess
    # For logic less mode, objects can be encased in the Wrapper class.
    # @api private
    class Wrapper
      attr_reader :value, :parent

      def initialize(value, parent = nil)
        @value, @parent = value, parent
      end

      # To find the reference, first check for standard method
      # access by using respond_to?.
      #
      # If not found, check to see if the value is a hash and if the
      # the name is a key on the hash.
      #
      # Not a hash, or not a key on the hash, then check to see if there
      # is an instance variable with the name.
      #
      # If the instance variable doesn't exist and there is a parent object,
      # go through the same steps on the parent object.  This is useful when
      # you are iterating over objects.
      def [](name)
        return wrap(value.send(name)) if value.respond_to?(name)
        if value.respond_to?(:has_key?)
          return wrap(value[name.to_sym]) if value.has_key?(name.to_sym)
          return wrap(value[name.to_s]) if value.has_key?(name.to_s)
        end
        begin
          var_name = "@#{name}"
          return wrap(value.instance_variable_get(var_name)) if value.instance_variable_defined?(var_name)
        rescue NameError
          # Do nothing
        end
        parent[name] if parent
      end

      # Empty objects must appear empty for inverted sections
      def empty?
        value.respond_to?(:empty) && value.empty?
      end

      # Used for output
      def to_s
        value.to_s
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
end
