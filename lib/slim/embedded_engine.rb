module Slim
  # Temple filter which processes embedded engines
  # @api private
  class EmbeddedEngine < Filter
    @engines = {}

    class << self
      attr_reader :engines

      # Register embedded engine
      #
      # @param [String] name Name of the engine
      # @param [Class]  klass Engine class
      # @param option_filter List of options to pass to engine.
      #                      Last argument can be default option hash.
      def register(name, klass, *option_filter)
        local_options = Hash === option_filter.last ? option_filter.pop : nil
        @engines[name.to_s] = [klass, option_filter, local_options]
      end
    end

    def on_slim_embedded(name, body)
      new_engine(name).on_slim_embedded(name, body)
    end

    protected

    def new_engine(name)
      name = name.to_s
      raise "Embedded engine #{name} is disabled" if (options[:enable_engines] && !options[:enable_engines].include?(name)) ||
                                                     (options[:disable_engines] && options[:disable_engines].include?(name))
      engine, option_filter, local_options = self.class.engines[name] || raise("Embedded engine #{name} not found")
      filtered_options = Hash[*option_filter.select {|k| options.include?(k) }.map {|k| [k, options[k]] }.flatten]
      engine.new(Temple::ImmutableHash.new(local_options, filtered_options))
    end

    def collect_text(body)
      body[1..-1].inject('') do |text, exp|
        exp[0] == :slim && exp[1] == :interpolate ? (text << exp[2]) : text
      end
    end

    # Basic tilt engine
    class TiltEngine < EmbeddedEngine
      def on_slim_embedded(engine, body)
        engine = Tilt[engine] || raise("Tilt engine #{engine} is not available.")
        render(engine, collect_text(body))
      end
    end

    # Tilt-based static template (evaluated at compile-time)
    class StaticTiltEngine < TiltEngine
      protected

      def render(engine, text)
        [:static, engine.new { text }.render]
      end
    end

    # Sass engine which supports :pretty option
    class SassEngine < StaticTiltEngine
      protected

      def render(engine, text)
        text = engine.new(:style => (options[:pretty] ? :expanded : :compressed), :cache => false) { text }.render
        text.chomp!
        [:static, options[:pretty] ? "\n#{text}\n" : text]
      end
    end

    # Tilt-based engine which is fully dynamically evaluated during runtime (Slow and uncached)
    class DynamicTiltEngine < StaticTiltEngine
      protected

      # Code to collect local variables
      COLLECT_LOCALS = %q{eval('{' + local_variables.select {|v| v[0] != ?_ }.map {|v| ":#{v}=>#{v}" }.join(',') + '}')}

      def render(engine, text)
        [:dynamic, "#{engine.name}.new { #{text.inspect} }.render(self, #{COLLECT_LOCALS})"]
      end
    end

    # Tilt-based engine which is precompiled
    class PrecompiledTiltEngine < StaticTiltEngine
      protected

      def render(engine, text)
        # WARNING: This is a bit of a hack. Tilt::Engine#precompiled is protected
        [:dynamic, engine.new { text }.send(:precompiled, {}).first]
      end
    end

    # Static template with interpolated ruby code
    class InterpolateTiltEngine < StaticTiltEngine
      protected

      def render(engine, text)
        [:slim, :interpolate, engine.new { text }.render]
      end
    end

    # ERB engine (uses the Temple ERB implementation)
    class ERBEngine < EmbeddedEngine
      def on_slim_embedded(engine, body)
        Temple::ERB::Parser.new.call(collect_text(body))
      end
    end

    # Tag wrapper engine
    # Generates a html tag and wraps another engine (specified via :engine option)
    class TagEngine < EmbeddedEngine
      def on_slim_embedded(engine, body)
        content = options[:engine] ? options[:engine].new(options).on_slim_embedded(engine, body) : [:multi, body]
        [:html, :tag, options[:tag], [:html, :attrs, *options[:attributes].map {|k, v| [:html, :attr, k, [:static, v]] }], content]
      end
    end

    # Embeds ruby code
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
    register :coffee,     TagEngine,  :tag => :script, :attributes => { :type => 'text/javascript' },  :engine => StaticTiltEngine
    register :less,       TagEngine,  :tag => :style,  :attributes => { :type => 'text/css' },         :engine => StaticTiltEngine
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
