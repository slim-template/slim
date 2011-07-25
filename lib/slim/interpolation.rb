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
      count, code = 1, ''

      until string.empty? || count == 0
        if string =~ /\A\{/
          count += 1
          code << string.slice!(0)
        elsif string =~ /\A\}/
          count -= 1
          if count == 0
            string.slice!(0)
          else
            code << string.slice!(0)
          end
        else
          code << string.slice!(0)
        end
      end

      raise "Text interpolation: Expected closing }" if count != 0

      return string, code
    end
  end
end
