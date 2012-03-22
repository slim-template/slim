module Slim
  # @api private
  class Shortcuts < Filter
    def initialize(options = {})
      super
      @shortcut = {}
      @options[:shortcut].each do |k,v|
        @shortcut[k] = if v =~ /\A([^\s]+)\s+([^\s]+)\Z/
                         [$1, $2]
                       else
                         [@options[:default_tag], v]
                       end
      end
    end

    # Handle tag expression `[:slim, :tag, name, attrs, content]`
    #
    # @param [String] name Tag name
    # @param [Array] attrs Temple expression
    # @param [Array] content Temple expression
    # @return [Array] Compiled temple expression
    def on_slim_tag(name, attrs, content = nil)
      name = @shortcut[name][0] if @shortcut[name]
      super
    end

    # Handle shortcut expression `[:slim, :shortcut, type, value]`
    #
    # @param [String] type Shortcut type
    # @param [String] value Shortcut value
    # @return [Array] Compiled temple expression
    def on_slim_shortcut(type, value)
      [:html, :attr, @shortcut[type][1], [:static, value]]
    end
  end
end
