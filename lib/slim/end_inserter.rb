module Slim
  # In Slim you don't need to close any blocks:
  #
  #   - if Slim.awesome?
  #     | But of course it is!
  #
  # However, the parser is not smart enough (and that's a good thing) to
  # automatically insert end's where they are needed. Luckily, this filter
  # does *exactly* that (and it does it well!)
  class EndInserter < Filter
    ELSE_CONTROL_WORDS = /^(else|elsif|when)\b/

    def on_multi(*exps)
      result = [:multi]
      # This variable is true if the previous line was
      # (1) a control code and (2) contained indented content.
      prev_indent = false

      exps.each do |exp|
        if control?(exp)
          if prev_indent
            # Two control code in a row. If this one is *not*
            # an else block, we should close the previous one.
            if exp[2] !~ ELSE_CONTROL_WORDS
              append_end(result)
            end
          else
            # Checks if the control code contains something.
            if !empty_exp?(exp[3])
              prev_indent = true
            end
          end
        elsif exp[0] != :newline
          # This is *not* a control code, so we should close the previous one.
          # Ignores newlines because they will be inserted after each line.
          if prev_indent
            append_end(result)
            prev_indent = false
          end
        end

        result << compile(exp)
      end

      # The last line can be a control code too.
      if prev_indent
        append_end(result)
        prev_indent = false
      end

      result
    end

    # Appends an end.
    def append_end(result)
      result << [:block, "end"]
    end

    # Checks if an expression is a Slim control code.
    def control?(exp)
      exp[0] == :slim && exp[1] == :control
    end
  end
end

