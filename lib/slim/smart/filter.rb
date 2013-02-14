module Slim
  module Smart
    # Perform newline processing in the
    # expressions `[:slim, :smart, Expression]`.
    #
    # @api private
    class Filter < ::Slim::Filter
      define_options :smart_text_end_chars => '([{',
                     :smart_text_begin_chars => ',.;:!?)]}'
    
      def initialize(opts = {})
        super
        @smart = false
        @prepend = false
        @append = false
        @prepend_re = /\A#{chars_re(options[:smart_text_begin_chars])}/
        @append_re = /#{chars_re(options[:smart_text_end_chars])}\Z/
      end
      
      def on_multi(*exps)
        # The [:multi] blocks serve two purposes.
        # On outer level, they collect the building blocks like
        # tags, verbatim text, or smart text.
        # Within smart text block, they collect the individual
        # lines in [:slim, :interpolate, string] blocks.
        #
        # Our goal here is to decide when we want to prepend and
        # append newlines to those individual interpolated lines.
        # 
        # On outer level, we choose to prepend every time, except
        # right after the opening tag or after other smart text block.
        # We also use the append flag to recognize the last expression before the closing tag.
        #
        # Within smart text block, we prepend only before the first line unless
        # the outer level tells us not to, and we append only after the last line,
        # unless the outer level tells us it is the last line before the closing tag.
        # Of course, this is later subject to the special begin/end characters
        # which may further suppress the newline at the corresponding line boundary.
        # Also note that the lines themselves are already correctly separated by newlines,
        # so we don't have to worry about that at all.
        block = [:multi]
        prev = nil
        last_exp = exps.reject{ |exp| exp.first == :newline }.last unless @smart && @append
        exps.each do |exp|
          @append = exp.equal?(last_exp)
          if @smart
            @prepend = false if prev
          else
            @prepend = prev && ( prev.first != :slim || prev[1] != :smart )
          end
          block << compile(exp)
          prev = exp unless exp.first == :newline
        end
        block
      end
      
      def on_slim_smart(content)
        @smart = true
        [ :slim, :smart, compile(content) ]
      ensure
        @smart = false
      end
      
      def on_slim_interpolate(string)
        return super unless @smart
        
        if @prepend && prepend?(string)
          string = "\n" + string 
        end
        if @append && append?(string)
          string += "\n"
        end

        [ :slim, :interpolate, string ]
      end
      
      private
      
      def chars_re(string)
        Regexp.union(string.split(//))
      end
      
      def prepend?(string)
        string !~ @prepend_re
      end
      
      def append?(string)
        string !~ @append_re
      end
      
    end
  end
end
