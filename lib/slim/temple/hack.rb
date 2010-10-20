module Slim
  class Temple::Hack
    def self.fix_on_capture!
      ::Temple::HTML::Fast.class_eval do
        def on_capture(name, content)
          [:capture, name, compile(content)]
        end
      end unless ::Temple::HTML::Fast.method_defined?(:on_capture)
    end
  end
end