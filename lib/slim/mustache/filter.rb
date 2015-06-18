module Slim
  module Mustache
    # Handle ~mustache syntax
    class Filter < ::Slim::Filter
      
      def on_slim_mustache(line, content)
        if match = line.match(/\A[#\^]([^ ]*)/)
          end_tag = match[1]
          [:multi, [:static, "{{#{line}}}"], compile(content), [:static, "{{/#{end_tag}}}"]]
        else
          on_slim_interpolate("~#{line}")
        end
      end
      
      def on_slim_interpolate(string)
        if match = string.match(/\A~([>!])?([\(]([^\)]+)[\)]|([^ ]+))(.*)/)
          prefix = match[1] ? "#{match[1]} " : ""
          text = match[3] || match[2]
          [:multi, [:static, "{{#{prefix}"], [:slim, :interpolate, text], [:static, "}}"], [:slim, :interpolate, match[5]]]
        else
          [:slim, :interpolate, string]
        end
      end
    end
    
  end
  
end
