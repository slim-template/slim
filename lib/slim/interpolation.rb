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
      begin
        case string
        when /\A\\#\{/
          # Escaped interpolation
          block << [:static, '#{']
          string = $'
        when /\A#\{/
          # Interpolation
          string, code = parse_expression($')
          escape = code !~ /\A\{.*\}\Z/
          block << [:slim, :output, escape, escape ? code : code[1..-2], [:multi]]
        when /\A([#\\]?[^#\\]*([#\\][^\\#\{][^#\\]*)*)/
          # Static text
          block << [:static, $&]
          string = $'
        end
      end until string.empty?
      block
    end

    protected

    def parse_expression(string)
      count, i = 1, 0
      while i < string.size && count != 0
        if string[i] == ?{
          count += 1
        elsif string[i] == ?}
          count -= 1
        end
        i += 1
      end

      raise(Temple::FilterError, "Text interpolation: Expected closing }") if count != 0

      return string[i..-1], string[0, i-1]
    end
  end
end
