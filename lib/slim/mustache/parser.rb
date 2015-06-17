module Slim

	class Parser

		alias_method :original_unknown_line_indicator, :unknown_line_indicator
		def unknown_line_indicator
			case @line
			when /\A~/
					# Mustache block
					@line = $' if $1
					parse_mustache
			else
				original_unknown_line_indicator
			end
		end

		def parse_mustache
			@line.slice!(0)
			block = [:multi]
			@stacks.last << [:slim, :mustache, @line, block]
			@stacks << block
		end

	end
end
