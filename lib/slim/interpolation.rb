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
        when /^\\(\#\{[^\}]*\})/
          # Escaped interpolation
          block << [:static, $1]
        when /^\#\{([^\}]*)\}/
          # Interpolation
          block << [:slim, :output, true, $1, [:multi]]
        when /^([^\#]+|\#)/
          # Static text
          block << [:static, $&]
        end
        string = $'
      end
      block
    end
  end
end
