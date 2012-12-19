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

      def section(name)
        if dict = scope[name]
          if dict.respond_to?(:call)
            dict.call do |new_dict|
              new_scope(new_dict) { yield }
            end
          elsif !dict.respond_to?(:has_key?) && dict.respond_to?(:each)
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

        def [](name)
          return @dict.send(name) if @dict.respond_to?(name)
          if @dict.respond_to?(:has_key?)
            return @dict[name] if @dict.has_key?(name)
            return @dict[name.to_s] if @dict.has_key?(name.to_s)
          end
          begin
            var_name = "@#{name}"
            return @dict.instance_variable_get(var_name) if @dict.instance_variable_defined?(var_name)
          rescue NameError
            # Do nothing
          end
          @parent[name] if @parent
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
