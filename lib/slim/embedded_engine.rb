module Slim
  # Temple filter which processes embedded engines
  # @api private
  class EmbeddedEngine < Filter
    @engines = {}

    class << self
      attr_reader :engines

      def register(name, klass, *option_filter)
        local_options = Hash === option_filter.last ? option_filter.pop : nil
        @engines[name.to_s] = [klass, option_filter, local_options]
      end
    end

    def new_engine(name)
      name = name.to_s
      raise "Embedded engine #{name} is disabled" if (options[:enable_engines] && !options[:enable_engines].include?(name)) ||
                                                     (options[:disable_engines] && options[:disable_engines].include?(name))
      engine, option_filter, local_options = self.class.engines[name] || raise("Embedded engine #{name} not found")
      filtered_options = Hash[*option_filter.select {|k| options.include?(k) }.map {|k| [k, options[k]] }.flatten]
      engine.new(Temple::ImmutableHash.new(local_options, filtered_options))
    end

    def on_slim_embedded(name, body)
      new_engine(name).on_slim_embedded(name, body)
    end

    def collect_text(body)
      body[1..-1].inject('') do |text, exp|
        exp[0] == :slim && exp[1] == :text ? (text << exp[2]) : text
      end
    end

    class TiltEngine < EmbeddedEngine
      def on_slim_embedded(engine, body)
        text = collect_text(body)
        engine = Tilt[engine] || raise("Tilt engine #{engine} is not available.")
        tilt_render(engine, text)
      end

      def tilt_render(engine, text)
        # Static template
        [:static, engine.new { text }.render]
      end
    end

    class SassEngine < TiltEngine
      def tilt_render(engine, text)
        text = engine.new(:style => (options[:pretty] ? :expanded : :compressed), :cache => false) { text }.render
        text.chomp!
        [:static, options[:pretty] ? "\n#{text}\n" : text]
      end
    end

    class DynamicTiltEngine < TiltEngine
      # Code to collect local variables
      COLLECT_LOCALS = %q{eval('{' + local_variables.select {|v| v[0] != ?_ }.map {|v| ":#{v}=>#{v}" }.join(',') + '}')}

      def tilt_render(engine, text)
        # Fully dynamic evaluation of the template during runtime (Slow and uncached)
        [:dynamic, "#{engine.name}.new { #{text.inspect} }.render(self, #{COLLECT_LOCALS})"]
      end
    end

    class PrecompiledTiltEngine < TiltEngine
      def tilt_render(engine, text)
        # Wrap precompiled code in proc, local variables from out the proc are accessible
        # WARNING: This is a bit of a hack. Tilt::Engine#precompiled is protected
        precompiled = engine.new { text }.send(:precompiled, {}).first
        [:dynamic, "proc { #{precompiled} }.call"]
      end
    end

    class InterpolateTiltEngine < TiltEngine
      def tilt_render(engine, text)
        # Static template with interpolated ruby code
        [:slim, :text, engine.new { text }.render]
      end
    end

    class ERBEngine < EmbeddedEngine
      def on_slim_embedded(engine, body)
        text = collect_text(body)
        Temple::ERB::Parser.new.call(text)
      end
    end

    class TagEngine < EmbeddedEngine
      def on_slim_embedded(engine, body)
        content = options[:engine] ? options[:engine].new(options).on_slim_embedded(engine, body) : [:multi, body]
        [:html, :tag, options[:tag], [:html, :attrs, *options[:attributes].map {|k, v| [:html, :attr, k, [:static, v]] }], content]
      end
    end

    class RubyEngine < EmbeddedEngine
      def on_slim_embedded(engine, body)
        [:code, collect_text(body)]
      end
    end

    # These engines are executed at compile time, embedded ruby is interpolated
    register :markdown,   InterpolateTiltEngine
    register :textile,    InterpolateTiltEngine
    register :rdoc,       InterpolateTiltEngine
    register :creole,     InterpolateTiltEngine

    # These engines are executed at compile time
    register :coffee,     TagEngine,  :tag => :script, :attributes => { :type => 'text/javascript' },  :engine => TiltEngine
    register :less,       TagEngine,  :tag => :style,  :attributes => { :type => 'text/css' },         :engine => TiltEngine
    register :sass,       TagEngine,  :pretty, :tag => :style, :attributes => { :type => 'text/css' }, :engine => SassEngine
    register :scss,       TagEngine,  :pretty, :tag => :style, :attributes => { :type => 'text/css' }, :engine => SassEngine

    # These engines are precompiled, code is embedded
    register :erb,        ERBEngine
    register :haml,       PrecompiledTiltEngine
    register :nokogiri,   PrecompiledTiltEngine
    register :builder,    PrecompiledTiltEngine

    # These engines are completely executed at runtime (Usage not recommended, no caching!)
    register :liquid,     DynamicTiltEngine
    register :radius,     DynamicTiltEngine
    register :markaby,    DynamicTiltEngine

    # Embedded javascript/css
    register :javascript, TagEngine,  :tag => :script, :attributes => { :type => 'text/javascript' }
    register :css,        TagEngine,  :tag => :style,  :attributes => { :type => 'text/css' }

    # Embedded ruby code
    register :ruby,       RubyEngine
  end
end
