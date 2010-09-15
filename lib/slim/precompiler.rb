# encoding: utf-8

module Slim
  module Precompiler
    AUTOCLOSED = %w(meta img link br hr input area param col base)

    REGEX = /^(\s*)(!?`?-?=?\w*)(\s*\w*=".+")?(.*)/

    def precompile
      @precompiled = "_buf = [];"

      last_indent = -1; enders = []

      @template.each_line do |line|
        line.chomp!; line.rstrip!

        line =~ REGEX

        indent        =   $1.to_s.length
        marker        =   $2

        line_type     = case marker
                        when '`' then :text
                        when '-' then :control_code
                        when '=' then :output_code
                        when '!' then :declaration
                        else :markup
                        end

        if $3
          tag_attrs = $3.gsub('"', '\"') 
        end

        if $4
          string    = $4.strip 
          string    = nil unless string.strip.length > 0
        end

        unless indent > last_indent
          begin
            break if enders.empty?
            continue_closing = true
            ender, ender_indent = enders.pop

            if ender_indent >= indent
              unless ender == 'end;' && line_type == :control_code
                @precompiled << ender
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
            @precompiled << "_buf << \"<#{marker}#{tag_attrs || ''}/>\";"
          else
            enders << ["_buf << \"</#{marker}>\";", indent]
            @precompiled << "_buf << \"<#{marker}#{tag_attrs || ''}>\";"
          end

          if string
            @precompiled << "_buf << \"#{string}\";"
          end
        when :text
          @precompiled << "_buf << \"#{string}\";"
        when :control_code
          unless enders.detect{|e| e[0] == 'end;' && e[1] == indent}
            enders << ['end;', indent]
          end
          @precompiled << "#{string};"
        when :output_code
          @precompiled << "_buf << #{string};"
        when :declaration
          @precompiled << "_buf << \"<! #{string} >\";"
        else
          raise NotImplementedError.new("Don't know how to parse line: #{line}")
        end
      end # template iterator

      enders.reverse_each do |t|
        @precompiled << t[0].to_s
      end

      @precompiled << "_buf.join;"
    end
  end
end
