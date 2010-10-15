# encoding: utf-8

require 'slim/optimizer'

module Slim
  module Compiler
    include Optimizer

    AUTOCLOSED         = %w{meta img link br hr input area param col base}
    CONTROL_WORDS      = %w{if unless do}
    ELSE_CONTROL_WORDS = %w{else elsif}

    REGEX_LINE_PARSER  = /^(\s*)(!?`?\|?-?=?\/?\w*)((?:\s*(?:\w|-)*="[^=]+")+|(\S*[#.]\S+))?(.*)/

    REGEX_LINE_CONTAINS_OUTPUT_CODE       = /^\s*=(.*)/
    REGEX_LINE_CONTAINS_METHOD_DETECTED   = /^((?:(?!#{CONTROL_WORDS * '\b|'}\b).)*)/
    REGEX_METHOD_HAS_NO_PARENTHESES       = /^\w+\s+\S+/
    REGEX_CODE_BLOCK_DETECTED             = / do ?.*$/
    REGEX_CODE_CONTROL_WORD_DETECTED      = /(?:\s|(\())(#{CONTROL_WORDS * '|'})\b\s?(.*)$/
    REGEX_CODE_ELSE_CONTROL_WORD_DETECTED = /^#{ELSE_CONTROL_WORDS * '\b|'}\b/
    REGEX_FIND_HTML_ATTR_ID               = /#([^.\s]+)/
    REGEX_FIND_HTML_ATTR_CLASSES          = /\.([^#\s]+)/

    def compile
      @_buffer    = ['_buf = [];']
      in_text     = false
      enders      = []
      text_indent = last_indent = -1

      @template.each_line do |line|
        line.chomp!
        line.rstrip!

        if line.length == 0
          @_buffer << '_buf << "<br/>";' if in_text
          next
        end

        line =~ REGEX_LINE_PARSER

        indent = $1.to_s.length

        if in_text && indent > text_indent
          spaces = indent - text_indent
          @_buffer << "_buf << \"#{(' '*(spaces - 1)) + line.lstrip}\";"
          next
        end

        marker         = $2
        attrs          = $3
        shortcut_attrs = $4
        string         = $5

        # Remove the first space, but allow people to pad if they want.
        string.slice!(0) if string =~ /^\s/

        # prepends "div" to the shortcut form of attrs if no marker is given
        marker = 'div' if shortcut_attrs && marker.empty?

        line_type = case marker
                    when '`', '|' then :text
                    when '-'      then :control_code
                    when '='      then :output_code
                    when '!'      then :declaration
                    when '/'      then next # simply ignore any ruby code comments
                    else :markup
                    end

        if attrs
          normalize_attributes!(attrs) if shortcut_attrs
          attrs.gsub!('"', '\"')
        end

        unless indent > last_indent
          begin
            break if enders.empty?
            continue_closing = true
            ender, ender_indent = enders.pop

            unless ender_indent < indent || ender == 'end;' && line_type == :control_code &&
              ender_indent == indent && string =~ REGEX_CODE_ELSE_CONTROL_WORD_DETECTED
                @_buffer << ender
            else
              enders << [ender, ender_indent]
              continue_closing = false
            end
          end while continue_closing == true
        end

        last_indent = indent

        case line_type
        when :markup
          if AUTOCLOSED.include?(marker)
            @_buffer << "_buf << \"<#{marker}#{attrs}/>\";"
          else
            enders   << ["_buf << \"</#{marker}>\";", indent]
            @_buffer << "_buf << \"<#{marker}#{attrs}>\";"
          end

          unless string.empty?
            if string =~ REGEX_LINE_CONTAINS_OUTPUT_CODE
              @_buffer << "_buf << #{parse_string($1.strip)};"
            else
              @_buffer << "_buf << \"#{string}\";"
            end
          end
        when :text
          in_text     = true
          text_indent = indent
          @_buffer << "_buf << \"#{string}\";" unless string.empty?
        when :control_code
          enders   << ['end;', indent] unless enders.detect{|e| e[0] == 'end;' && e[1] == indent}
          @_buffer << "#{string};"
        when :output_code
          enders   << ['end;', indent] if string =~ REGEX_CODE_BLOCK_DETECTED
          @_buffer << "_buf << #{parse_string(string)};"
        when :declaration
          @_buffer << "_buf << \"<!#{string}>\";"
        else
          raise NotImplementedError.new("Don't know how to parse line: #{line}")
        end
      end # template iterator

      enders.reverse_each do |t|
        @_buffer << t[0]
      end

      @_buffer << "_buf.join;"

      @compiled  = @_buffer.join
      @optimized = optimize!
    end

    private

    def parse_string(string)
      if string =~ REGEX_LINE_CONTAINS_OUTPUT_CODE
        $1.strip
      else
        parenthesesify_method!(string)  if string =~ REGEX_METHOD_HAS_NO_PARENTHESES
        wraps_with_slim_escape!(string) unless string =~ REGEX_CODE_BLOCK_DETECTED
        string.strip
      end
    end

    # adds a pair of parentheses to the method
    def parenthesesify_method!(string)
      string.sub!(' ', '(') && string.sub!(REGEX_CODE_CONTROL_WORD_DETECTED, '\1) \2 \3') || string << ')'
    end

    # escapes the string
    def wraps_with_slim_escape!(string)
      string.sub!(REGEX_LINE_CONTAINS_METHOD_DETECTED, 'Slim.escape_html(\1)')
    end

    # converts 'p#hello.world.mate' to 'p id="hello" class="world mate"'
    def normalize_attributes!(string)
      string.sub!(REGEX_FIND_HTML_ATTR_ID, ' id="\1"')
      string.sub!(REGEX_FIND_HTML_ATTR_CLASSES, ' class="\1"')
      string.gsub!('.', ' ')
    end
  end
end
