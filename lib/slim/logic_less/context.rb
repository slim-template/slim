module Slim
  class LogicLess
    # @api private
    class Context
      def initialize(dict)
        @scope = [Scope.new(dict)]
      end

      def [](name)
        scope[name]
      end

      def lambda(name)
        scope.lambda(name) do |dict|
          new_scope(dict) { yield }
        end
      end

      def section(name)
        if dict = scope[name]
          if !dict.respond_to?(:has_key?) && dict.respond_to?(:each)
            new_scope do
              dict.each do |d|
                scope.dict = d
                yield
              end
            end
          else
            new_scope(dict) { yield }
          end
        end
      end

      def inverted_section(name)
        value = scope[name]
        yield if !value || (value.respond_to?(:empty?) && value.empty?)
      end

      private

      class Scope
        attr_writer :dict

        def initialize(dict, parent = nil)
          @dict, @parent = dict, parent
        end

        def lambda(name, &block)
          return @dict.send(name, &block) if @dict.respond_to?(name)
          if @dict.respond_to?(:has_key?)
            return @dict[name].call(&block) if @dict.has_key?(name)
            return @dict[name.to_s].call(&block) if @dict.has_key?(name.to_s)
          end
          var_name = "@#{name}"
          return @dict.instance_variable_get(var_name).call(&block) if instance_variable?(var_name)
          @parent.lambda(name) if @parent
        end

        def [](name)
          return @dict.send(name) if @dict.respond_to?(name)
          if @dict.respond_to?(:has_key?)
            return @dict[name] if @dict.has_key?(name)
            return @dict[name.to_s] if @dict.has_key?(name.to_s)
          end
          var_name = "@#{name}"
          return @dict.instance_variable_get(var_name) if instance_variable?(var_name)
          @parent[name] if @parent
        end

        private

        def instance_variable?(name)
          begin
            @dict.instance_variable_defined?(name)
          rescue NameError
            false
          end
        end
      end

      def scope
        @scope.last
      end

      def new_scope(dict = nil)
        @scope << Scope.new(dict, scope)
        yield
      ensure
        @scope.pop
      end
    end
  end
end
