module Slim
  # Perform newline processing in the
  # expressions `[:slim, :smart, Expression]`.
  #
  # @api private
  class SmartText < Filter
    # Handle smart text expression `[:slim, :smart, Expression]`
    #
    # @param [String] content Temple expression
    # @return [Array] Compiled temple expression
    def on_slim_smart(content)
      return [ :slim, :text, compile(content) ]
    end

  end
end
