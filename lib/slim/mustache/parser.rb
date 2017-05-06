module Slim
  
  module Mustache

    class Parser < ::Slim::Parser
  
      def parse_line_indicators
        case @line
        when /\A~/
            # Mustache block
            @line = $' if $1
            parse_mustache
        else
          super
        end
      end
  
      def parse_mustache
        @line.slice!(0)
        block = [:multi]
        @stacks.last << [:slim, :mustache, @line, block]
        @stacks << block
      end
      
    end

  end
end
