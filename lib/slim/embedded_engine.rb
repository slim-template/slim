module Slim
  # @api private
  class CollectText < Filter
    def call(exp)
      @collected = ''
      super(exp)
      @collected
    end

    def on_slim_interpolate(text)
      @collected << text
      nil
    end
  end

  # @api private
  class CollectNewlines < Filter
    def call(exp)
      @collected = [:multi]
      super(exp)
      @collected
    end

    def on_newline
      @collected << [:newline]
      nil
    end
  end

  # @api private
  class ProtectOutput < Filter
    def call(exp)
      @protect = []
      @collected = ''
      super(exp)
      @collected
    end

    def on_static(text)
      @collected << text
      nil
    end

    def on_slim_output(escape, text, content)
      @collected << "pro#{@protect.size}tect"
      @protect << [:slim, :output, escape, text, content]
      nil
    end

    def unprotect(text)
      block = [:multi]
      while text =~ /pro(\d+)tect/
        block << [:static, $`]
        block << @protect[$1.to_i]
        text = $'
      end
      block << [:static, text]
    end
  end

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
      name = name.to_s
      raise "Embedded engine #{name} is disabled" if (options[:enable_engines] && !options[:enable_engines].include?(name)) ||
                                                     (options[:disable_engines] && options[:disable_engines].include?(name))
      engine, option_filter, local_options = self.class.engines[name] || raise("Embedded engine #{name} not found")
      filtered_options = Hash[*option_filter.select {|k| options.include?(k) }.map {|k| [k, options[k]] }.flatten]
      engine.new(Temple::ImmutableHash.new(local_options, filtered_options)).on_slim_embedded(name, body)
    end

    # Basic tilt engine
    class TiltEngine < EmbeddedEngine
      def on_slim_embedded(engine, body)
        tilt_engine = Tilt[engine] || raise("Tilt engine #{engine} is not available.")
        tilt_options = options[engine.to_sym] || {}
        [:multi, tilt_render(tilt_engine, tilt_options, collect_text(body)), CollectNewlines.new.call(body)]
      end

      protected

      def collect_text(body)
        CollectText.new.call(body)
      end
    end

    # Tilt-based static template (evaluated at compile-time)
    class StaticTiltEngine < TiltEngine
      protected

      def tilt_render(tilt_engine, tilt_options, text)
        [:static, tilt_engine.new(tilt_options) { text }.render]
      end
    end

    # Sass engine which supports :pretty option
    class SassEngine < TiltEngine
      protected

      def tilt_render(tilt_engine, tilt_options, text)
        text = tilt_engine.new(tilt_options.merge(
          :style => (options[:pretty] ? :expanded : :compressed), :cache => false)) { text }.render
        text.chomp!
        [:static, options[:pretty] ? "\n#{text}\n" : text]
      end
    end

    # Tilt-based engine which is precompiled
    class PrecompiledTiltEngine < TiltEngine
      protected

      def tilt_render(tilt_engine, tilt_options, text)
        # WARNING: This is a bit of a hack. Tilt::Engine#precompiled is protected
        [:dynamic, tilt_engine.new(tilt_options) { text }.send(:precompiled, {}).first]
      end
    end

    # Static template with interpolated ruby code
    class InterpolateTiltEngine < TiltEngine
      def initialize(opts = {})
        super
        @protect = ProtectOutput.new
      end

      def collect_text(body)
        text = Interpolation.new.call(body)
        @protect.call(text)
      end

      def tilt_render(tilt_engine, tilt_options, text)
        @protect.unprotect(tilt_engine.new(tilt_options) { text }.render)
      end
    end

    # ERB engine (uses the Temple ERB implementation)
    class ERBEngine < EmbeddedEngine
      def on_slim_embedded(engine, body)
        Temple::ERB::Parser.new.call(CollectText.new.call(body))
      end
    end

    # Tag wrapper engine
    # Generates a html tag and wraps another engine (specified via :engine option)
    class TagEngine < EmbeddedEngine
      def on_slim_embedded(engine, body)
        content = options[:engine] ? options[:engine].new(options).on_slim_embedded(engine, body) : body
        [:html, :tag, options[:tag], [:html, :attrs, *options[:attributes].map {|k, v| [:html, :attr, k, [:static, v]] }], content]
      end
    end

    # Embeds ruby code
    class RubyEngine < EmbeddedEngine
      def on_slim_embedded(engine, body)
        [:code, CollectText.new.call(body) + "\n"]
      end
    end

    # These engines are executed at compile time, embedded ruby is interpolated
    register :markdown,   InterpolateTiltEngine
    register :textile,    InterpolateTiltEngine
    register :rdoc,       InterpolateTiltEngine
    register :creole,     InterpolateTiltEngine
    register :wiki,       InterpolateTiltEngine

    # These engines are executed at compile time
    register :coffee,     TagEngine,  :tag => :script, :attributes => { :type => 'text/javascript' },  :engine => StaticTiltEngine
    register :less,       TagEngine,  :tag => :style,  :attributes => { :type => 'text/css' },         :engine => StaticTiltEngine
    register :sass,       TagEngine,  :pretty, :tag => :style, :attributes => { :type => 'text/css' }, :engine => SassEngine
    register :scss,       TagEngine,  :pretty, :tag => :style, :attributes => { :type => 'text/css' }, :engine => SassEngine

    # These engines are precompiled, code is embedded
    register :erb,        ERBEngine
    register :nokogiri,   PrecompiledTiltEngine
    register :builder,    PrecompiledTiltEngine

    # Embedded javascript/css
    register :javascript, TagEngine,  :tag => :script, :attributes => { :type => 'text/javascript' }
    register :css,        TagEngine,  :tag => :style,  :attributes => { :type => 'text/css' }

    # Embedded ruby code
    register :ruby,       RubyEngine
  end
end
