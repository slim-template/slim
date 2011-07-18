module Slim
  # Perform interpolation of #{var_name} in the
  # expressions `[:slim, :interpolate, string]`.
  #
  # @api private
  class Interpolation < Filter
    # Handle interpolate expression `[:slim, :interpolate, string]`
    #
    # @param [String] string Static interpolate
    # @return [Array] Compiled temple expression
    def on_slim_interpolate(string)
      # Interpolate variables in text (#{variable}).
      # Split the text into multiple dynamic and static parts.
      block = [:multi]
      until string.empty?
        case string
        when /\A\\#\{/
          # Escaped interpolation
          # HACK: Use :slim :output because this is used by InterpolateTiltEngine
          # to filter out protected strings (Issue #141).
          block << [:slim, :output, false, '\'#{\'', [:multi]]
          string = $'
        when /\A#\{/
          # Interpolation
          string, code = parse_expression($')
          escape = code !~ /\A\{.*\}\Z/
          block << [:slim, :output, escape, escape ? code : code[1..-2], [:multi]]
        when /\A([^#]+|#)/
          # Static text
          block << [:static, $&]
          string = $'
        end
      end
      block
    end

    protected

    def parse_expression(string)
      stack, code = [], ''

      until string.empty?
        if stack.empty? && string =~ /\A\}/
          # Stack is empty, this means we are finished
          # if the next character is a closing bracket
          string.slice!(0)
          break
        elsif string =~ Parser::DELIMITER_REGEX
          # Delimiter found, push it on the stack
          stack << Parser::DELIMITERS[$&]
          code << string.slice!(0)
        elsif string =~ Parser::CLOSE_DELIMITER_REGEX
          # Closing delimiter found, pop it from the stack if everything is ok
          raise "Text interpolation: Unexpected closing #{$&}" if stack.empty?
          raise "Text interpolation: Expected closing #{stack.last}" if stack.last != $&
          code << string.slice!(0)
          stack.pop
        else
          code << string.slice!(0)
        end
      end

      return string, code
    end
  end
end
