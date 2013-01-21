module Slim
  # Perform newline processing in the
  # expressions `[:slim, :smart, Expression]`.
  #
  # @api private
  class SmartText < Filter
    define_options :smart_text_end_chars => '([{',
                   :smart_text_begin_chars => ',.;:!?)]}'
  
    def initialize(opts = {})
      super
      @smart = false
      @prepend = false
      @append = false
      @prepend_re = /\A(?:#{chars_re(options[:smart_text_begin_chars])})/
      @append_re = /(?:#{chars_re(options[:smart_text_end_chars])})\Z/
    end
    
    def on_multi(*exps)
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
      old = @smart
      @smart = true
      [ :slim, :smart, compile(content) ]
    ensure
      @smart = old
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
