module Slim
  # This is taken direcly from ActiveSupport::StringInquirer
  class StringInquirer < String
    def method_missing(method_name, *arguments)
      if method_name.to_s[-1,1] == "?"
        self == method_name.to_s[0..-2]
      else
        super
      end
    end
  end
end
