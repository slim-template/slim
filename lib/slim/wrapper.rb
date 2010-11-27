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

    # To find the reference, first check for standard method
    # access by using respond_to?.
    #
    # If not found, check to see if the context is a hash and if the
    # the name is a key on the hash.
    #
    # Not a hash, or not a key on the hash, then check to see if there
    # is an instance variable with the name in the context.
    #
    # If the instance variable doesn't exist and there is a parent object,
    # go through the same steps on the parent object.  This is useful when
    # you are iterating over objects.  The context would be your current
    # object in the iteration, but the parent will be the global context.
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

    # Don't want to wrap basic objects
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
