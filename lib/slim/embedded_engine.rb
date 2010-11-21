module Slim
  # Temple filter which processes embedded engines
  # @api private
  class EmbeddedEngine < Filter
    @engines = {}

    def self.register(name, klass, options = {})
      @engines[name.to_s] = klass.new(options)
    end

    def self.[](name)
      engine = @engines[name.to_s]
      raise "Invalid embedded engine #{name}" if !engine
      engine.dup
    end

    def on_slim_embedded(name, *body)
      engine = EmbeddedEngine[name]
      raise "Embedded engine #{name} is disabled" if (options[:enable_engines] && !options[:enable_engines].include?(name)) ||
                                                     (options[:disable_engines] && options[:disable_engines].include?(name))
      engine.on_slim_embedded(name, *body)
    end

    def collect_text(body)
      body.inject('') do |text, exp|
        text << exp[2] if exp[0] == :slim && exp[1] == :text
        text
      end
    end

    class TiltEngine < EmbeddedEngine
      # Code to collect local variables
      COLLECT_LOCALS = %q{eval('{' + local_variables.select {|v| v[0] != ?_ }.map {|v| ":#{v}=>#{v}" }.join(',') + '}')}

      def on_slim_embedded(engine, *body)
        text = collect_text(body)
        engine = Tilt[engine]
        if options[:precompiled]
          # Wrap precompiled code in proc, local variables from out the proc are accessible
          # WARNING: This is a bit of a hack. Tilt::Engine#precompiled is protected
          precompiled = engine.new { text }.send(:precompiled, {}).first
          [:dynamic, "proc { #{precompiled} }.call"]
        elsif options[:dynamic]
          # Fully dynamic evaluation of the template during runtime (Slow and uncached)
          [:dynamic, "#{engine.name}.new { #{text.inspect} }.render(self, #{COLLECT_LOCALS})"]
        elsif options[:interpolate]
          # Static template with interpolated ruby code
          [:slim, :text, engine.new { text }.render]
        else
          # Static template
          [:static, engine.new { text }.render]
        end
      end
    end

    class ERBEngine < EmbeddedEngine
      def on_slim_embedded(engine, *body)
        text = collect_text(body)
        Temple::ERB::Parser.new(:auto_escape => true).compile(text)
      end
    end

    class TagEngine < EmbeddedEngine
      def on_slim_embedded(engine, *body)
        content = options[:engine] ? options[:engine].new.on_slim_embedded(engine, *body) : [:multi, *body]
        [:slim, :tag, options[:tag], [:slim, :attrs, *options[:attributes].map {|k, v| [k, [:static, v]] }], false, content]
      end
    end

    class RubyEngine < EmbeddedEngine
      def on_slim_embedded(engine, *body)
        [:block, collect_text(body)]
      end
    end

    # These engines are executed at compile time, embedded ruby is interpolated
    register :markdown, TiltEngine, :interpolate => true
    register :textile, TiltEngine, :interpolate => true
    register :rdoc, TiltEngine, :interpolate => true

    # These engines are executed at compile time
    register :coffee, TagEngine, :tag => 'script', :attributes => { :type => 'text/javascript' }, :engine => TiltEngine
    register :sass, TagEngine, :tag => 'style', :attributes => { :type => 'text/css' }, :engine => TiltEngine
    register :scss, TagEngine, :tag => 'style', :attributes => { :type => 'text/css' }, :engine => TiltEngine
    register :less, TagEngine, :tag => 'style', :attributes => { :type => 'text/css' }, :engine => TiltEngine

    # These engines are precompiled, code is embedded
    register :erb, ERBEngine
    register :haml, TiltEngine, :precompiled => true
    register :nokogiri, TiltEngine, :precompiled => true
    register :builder, TiltEngine, :precompiled => true

    # These engines are completely executed at runtime (Usage not recommended, no caching!)
    register :liquid, TiltEngine, :dynamic => true
    register :radius, TiltEngine, :dynamic => true
    register :markaby, TiltEngine, :dynamic => true

    # Embedded javascript/css
    register :javascript, TagEngine, :tag => 'script', :attributes => { :type => 'text/javascript' }
    register :css, TagEngine, :tag => 'style', :attributes => { :type => 'text/css' }

    # Embedded ruby code
    register :ruby, RubyEngine
  end
end
