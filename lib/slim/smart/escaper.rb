module Slim
  module Smart
    # Perform smart entity escaping in the
    # expressions `[:slim, :text, type, Expression]`.
    #
    # @api private
    class Escaper < ::Slim::Filter
      define_options :smart_text_escaping => true
    
      def initialize(opts = {})
        super
        @escape = false
        @enabled = options[:smart_text_escaping]
      end
      
      def on_slim_text(type, content)
        @escape = @enabled && type != :verbatim
        [ :escape, @escape, [ :slim, :text, type, compile(content) ] ]
      ensure
        @escape = false
      end
      
      def on_static(string)
        return [:static, string] unless @escape
        
        # Prevent obvious &foo; and &#1234; and &#x00ff; entities from escaping.
        # There is not much we can do about semicolon-less forms like &copy,
        # but they always have the option of using the version with semicolon instead.

        block = [:multi]
        begin
          case string
          when /\A&(\w+|#x[0-9a-f]+|#\d+);/i
            # Entity.
            block << [ :escape, false, [:static, $&] ]
            string = $'
          when /\A&?[^&]*/
            # Other text.
            block << [:static, $&]
            string = $'
          end
        end until string.empty?
        block
      end

    end
  end
end
