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
    end
    
    def on_multi(*exps)
      block = [:multi]
      prev = nil
      last_exp = exps.reject{ |exp| exp.first == :newline }.last if @smart
      exps.each do |exp|
        @prepend = true unless @smart
        @prepend = false if prev && prev.first == :slim && prev[1] == :smart
        @append = exp.equal? last_exp
        block << compile(exp)
        next if exp.first == :newline
        @prepend = false
        prev = exp
      end
      block
    end
  
    def on_slim_smart(content)
      old = @smart
      @smart = true
      [ :slim, :text, compile(content) ]
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
    
    def prepend?(string)
      not options[:smart_text_begin_chars][string[0]]
    end
    
    def append?(string)
      not options[:smart_text_end_chars][string[-1]]
    end
    
  end
end
