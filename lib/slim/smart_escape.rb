module Slim
  # Perform smart entity escaping in the
  # expressions `[:slim, :smart, Expression]`.
  #
  # @api private
  class SmartEscape < Filter
  
    def initialize(opts = {})
      super
      @smart = false
    end
    
    def on_slim_smart(content)
      old = @smart
      @smart = true
      [ :escape, true, [ :slim, :text, compile(content) ] ]
    ensure
      @smart = old
    end
    
    def on_static(string)
      return [:static, string] unless @smart
      
      # Prevent obvious &foo; and &#1234; and &#x00ff; entities from escaping.

      block = [:multi]
      begin
        case string
        when /\A&(\w+|#x\h+|#\d+);/i
          # Entity.
          block << [ :escape, false, [:static, $&] ]
          string = $'
        when /\A(&|[^&]*)/
          # Other text.
          block << [:static, $&]
          string = $'
        end
      end until string.empty?
      block
    end

  end
end
