module Slim
  # For logic-less mode, objects are encased in the Wrapper class.
  #
  # For Rails, this allows us to use the environment provided for rendering
  # a view including the instance variables, view helper and application helper
  # methods.
  class Wrapper
    attr_reader :context, :parent

    def initialize(context, parent = nil)
      @context = context
      @parent  = parent
    end

    def [](name)
      result = call(name)
      if result.kind_of?(Array)
        result.collect{|r| maybe_wrap(r)}
      else
        maybe_wrap(result)
      end
    end

    private
    def call(name, ctx = context)
      varname = :"@#{name}"

      if ctx.respond_to?(name) 
        ctx.send(name)
      elsif ctx.respond_to?(:has_key?) && ctx.has_key?(name.to_sym)
        ctx[name.to_sym]
      elsif ctx.instance_variables.include?(varname)
        ctx.instance_variable_get(varname)
      elsif parent
        call(name, parent) 
      else 
        raise NameError.new("Could not find reference to #{name} or @#{name} in context.")
      end
    end

    def maybe_wrap(item)
      return unless item
      if item.kind_of?(String) || item.kind_of?(Numeric)
        item
      else
        Slim::Wrapper.new(item, context)
      end
    end

  end
end
