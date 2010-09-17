# encoding: utf-8

require 'slim/optimizer'

module Slim
  module Compiler
    include Optimizer
    AUTOCLOSED = %w(meta img link br hr input area param col base)

    REGEX = /^(\s*)(!?`?-?=?\w*)(\s*\w*=".+")?(.*)/

    def compile
      @_buffer = ["_buf = [];"]

      last_indent = -1; enders = []

      @template.each_line do |line|
        line.chomp!; line.rstrip!


        next if line.length == 0

        line =~ REGEX

        indent        =   $1.to_s.length
        marker        =   $2
        attrs         =   $3
        string        =   $4 

        line_type     = case marker
                        when '`' then :text
                        when '-' then :control_code
                        when '=' then :output_code
                        when '!' then :declaration
                        else :markup
                        end

        if attrs
          attrs.gsub!('"', '\"') 
        end

        if string
          string.strip!
          string    = nil unless string.strip.length > 0
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
            enders << ["_buf << \"</#{marker}>\";", indent]
            @_buffer << "_buf << \"<#{marker}#{attrs || ''}>\";"
          end

          if string
            string.lstrip!
            if string =~ /^=(.*)/
              @_buffer << "_buf << #{$1.strip};"
            else
              @_buffer << "_buf << \"#{string}\";"
            end
          end
        when :text
          @_buffer << "_buf << \"#{string}\";"
        when :control_code
          unless enders.detect{|e| e[0] == 'end;' && e[1] == indent}
            enders << ['end;', indent]
          end
          @_buffer << "#{string};"
        when :output_code
          @_buffer << "_buf << #{string};"
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
  end
end
