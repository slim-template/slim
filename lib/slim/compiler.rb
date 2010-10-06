# encoding: utf-8

require 'slim/optimizer'

module Slim
  module Compiler
    include Optimizer
    AUTOCLOSED = %w(meta img link br hr input area param col base)

    CONTROL_WORDS = %w{if else elsif do}

    REGEX_LINE_PARSER                = /^(\s*)(!?`?\|?-?=?\w*)((?:\s*(?:\w|-)*="[^=]+")+|(\s*[#.]\S+))?(.*)/
    REGEX_LINE_CONTAINS_OUTPUT_CODE  = /^=(.*)/
    REGEX_METHOD_HAS_NO_PARENTHESES  = /^\w+( )/
    REGEX_CODE_BLOCK_DETECTED        = / do ?(.*)$/
    REGEX_CODE_CONTROL_WORD_DETECTED = /(?:( )|(\())(#{CONTROL_WORDS * '|'})\b ?(.*)$/
    REGEX_FIND_ATTR_ID               = /#([^.\s]+)/
    REGEX_FIND_ATTR_CLASS            = /\.([^#\s]+)/

    def compile
      @_buffer = ["_buf = [];"]
      @in_text = false

      text_indent = last_indent = -1; enders = []

      @template.each_line do |line|
        line.chomp!; line.rstrip!

        if line.length == 0
          @_buffer << "_buf << \"<br/>\";" if @in_text
          next 
        end

        line =~ REGEX_LINE_PARSER

        indent = $1.to_s.length

        if @in_text && indent > text_indent
          spaces = indent - text_indent
          @_buffer << "_buf << \"#{(' '*(spaces - 1)) + line.lstrip}\";"
          next
        end

        marker         = $2
        attrs          = $3
        shortcut_attrs = $4
        string         = $5

        # prepends "div" to the shortcut form of attrs if no marker is given
        if shortcut_attrs && marker.empty?
          marker = "div"
        end

        line_type = case marker
                    when '`', '|' then :text
                    when '-'      then :control_code
                    when '='      then :output_code
                    when '!'      then :declaration
                    else :markup
                    end

        if line_type != :text
          @in_text    = false
          text_indent = -1
        end

        if attrs
          attrs = normalize_attributes(attrs) if shortcut_attrs
          attrs.gsub!('"', '\"')
        end

        if string
          string.strip!
          string = nil if string.empty?
        end

        unless indent > last_indent
          begin
            break if enders.empty?
            continue_closing = true
            ender, ender_indent = enders.pop

            if ender_indent >= indent
              unless ender == 'end;' && line_type == :control_code && ender_indent == indent
                @_buffer << ender
              end
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
            @_buffer << "_buf << \"<#{marker}#{attrs || ''}/>\";"
          else
            enders   << ["_buf << \"</#{marker}>\";", indent]
            @_buffer << "_buf << \"<#{marker}#{attrs || ''}>\";"
          end

          if string
            string.lstrip!
            if string =~ REGEX_LINE_CONTAINS_OUTPUT_CODE
              @_buffer << "_buf << #{parenthesesify_method($1.strip)};"
            else
              @_buffer << "_buf << \"#{string}\";"
            end
          end
        when :text
          @in_text    = true
          text_indent = indent
          @_buffer << "_buf << \"#{string}\";" if string.to_s.length > 0
        when :control_code
          enders   << ['end;', indent] unless enders.detect{|e| e[0] == 'end;' && e[1] == indent}
          @_buffer << "#{string};"
        when :output_code
          enders   << ['end;', indent] if string =~ REGEX_CODE_BLOCK_DETECTED
          @_buffer << "_buf << #{parenthesesify_method(string)};"
        when :declaration
          @_buffer << "_buf << \"<!#{string}>\";"
        else
          raise NotImplementedError.new("Don't know how to parse line: #{line}")
        end
      end # template iterator

      enders.reverse_each do |t|
        @_buffer << t[0].to_s
      end

      @_buffer << "_buf.join;"

      @compiled = @_buffer.join

      optimize

      return nil
    end

    private

    # adds a pair of parentheses to the method
    def parenthesesify_method(string)
      if string =~ REGEX_METHOD_HAS_NO_PARENTHESES
        string.sub!(' ', '(') && string.sub!(REGEX_CODE_CONTROL_WORD_DETECTED, '\2) \3 \4') || string << ')'
      end
      string
    end

    # converts 'p#hello.world' to 'p id="hello" class="world"'
    def normalize_attributes(string)
      string.sub!(REGEX_FIND_ATTR_ID, ' id="\1"')
      string.sub!(REGEX_FIND_ATTR_CLASS, ' class="\1"')
      string.gsub!('.', ' ')
      string
    end
  end
end
