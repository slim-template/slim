module Slim
  class EmbeddedEngine
    @engines = {}

    attr_reader :options

    def initialize(options)
      @options = options
    end

    def self.[](name)
      engine = @engines[name.to_s]
      raise "Invalid embedded engine #{name}" if !engine
      engine.dup
    end

    def self.register(name, klass, options = {})
      options.merge!(:name => name.to_s)
      @engines[name.to_s] = klass.new(options)
    end

    def collect_text(body)
      body.inject('') do |text, exp|
        if exp[0] == :slim && exp[1] == :text
          text << exp[2]
        elsif exp[0] == :newline
          text << "\n"
        end
        text
      end
    end

    class TiltEngine < EmbeddedEngine
      def compile(body)
        text = collect_text(body)
        engine = Tilt[options[:name]]
        if options[:dynamic]
          [:dynamic, "#{engine.name}.new { #{text.inspect} }.render(self)"]
        elsif options[:interpolate]
          [:dynamic, '"%s"' % engine.new { text }.render]
        else
          [:static, engine.new { text }.render]
        end
      end
    end

    class TagEngine < EmbeddedEngine
      def compile_text(body)
        body.inject([:multi]) do |block, exp|
          block << (exp[0] == :slim && exp[1] == :text ? [:static, exp[2]] : exp)
        end
      end

      def compile(body)
        attrs = [:html, :attrs]
        options[:attributes].each do |key, value|
          attrs << [:html, :basicattr, [:static, key.to_s], [:static, value.to_s]]
        end
        [:html, :tag, options[:tag], attrs, compile_text(body)]
      end
    end

    class RubyEngine < EmbeddedEngine
      def compile(body)
        [:block, collect_text(body)]
      end
    end

    # These engines are executed at compile time, text is evaluated
    register :markdown, TiltEngine, :interpolate => true
    register :textile, TiltEngine, :interpolate => true
    register :rdoc, TiltEngine, :interpolate => true

    # These engines are executed at compile time
    register :sass, TiltEngine
    register :less, TiltEngine
    register :coffee, TiltEngine

    # These engines are executed at runtime
    register :erb, TiltEngine, :dynamic => true
    register :haml, TiltEngine, :dynamic => true
    register :builder, TiltEngine, :dynamic => true
    register :liquid, TiltEngine, :dynamic => true
    register :radius, TiltEngine, :dynamic => true
    register :markaby, TiltEngine, :dynamic => true
    register :nokogiri, TiltEngine, :dynamic => true

    # Embedded javascript/css
    register :javascript, TagEngine, :tag => 'script', :attributes => { :type => 'text/javascript' }
    register :css, TagEngine, :tag => 'style', :attributes => { :type => 'text/css' }

    # Embedded ruby code
    register :ruby, RubyEngine
  end
end
