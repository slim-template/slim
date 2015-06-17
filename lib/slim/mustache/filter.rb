
module Slim
	module Mustache
		# Handle ~mustache syntax
		class Filter < ::Slim::Interpolation
			
			def on_slim_mustache(line, content)
				if match = line.match(/\A[#\^]([^ ]*)/)
					end_tag = match[1]
					[:multi, [:static, "{{#{line}}}"], compile(content), [:static, "{{/#{end_tag}}}"]]
				else
					on_slim_interpolate("~#{line}")
				end
			end
			
			alias_method :orginal_on_slim_interpolate, :on_slim_interpolate
			def on_slim_interpolate(string)
				if match = string.match(/\A~([>!])?(["'\(]([^\)"']+)[\)"']|([^ ]+))(.*)/)
					prefix = match[1] ? "#{match[1]} " : ""
					text = match[3] || match[2]
					[:multi, [:static, "{{#{prefix}#{text}}}"], [:slim, :interpolate, match[5]]]
				else
					orginal_on_slim_interpolate(string)
				end
			end
		end
		
	end
	
end