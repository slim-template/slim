module Slim
  # Perform interpolation of #{var_name}
  # @api private
  class Interpolation < Filter
    # Handle text expression `[:slim, :text, string]`
    #
    # @param [String] string Static text
    # @return [Array] Compiled temple expression
    def on_slim_text(string)
      # Interpolate variables in text (#{variable}).
      # Split the text into multiple dynamic and static parts.
      block = [:multi]
      until string.empty?
        case string
        when /^\\#\{/
          # Escaped interpolation
          block << [:static, '#{']
          string = $'
        when /^#\{/
          # Interpolation
          string, code = parse_expression($')
          escape = code !~ Parser::DELIMITER_REGEX || Parser::DELIMITERS[$&] != code[-1, 1]
          block << [:slim, :output, escape, escape ? code : code[1..-2], [:multi]]
        when /^([^#]+|#)/
          # Static text
          block << [:static, $&]
          string = $'
        end
      end
      block
    end

    def parse_expression(string)
      stack, code = [], ''

      until string.empty?
        if stack.empty? && string =~ /^\}/
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
