require 'slim'

module Slim
  class Translator < Filter
    set_default_options :tr_mode => :dynamic,
                        :tr_fn   => '_'

    if Object.const_defined?(:I18n)
      set_default_options :tr_fn => '::Slim::Translator.i18n_text',
                          :tr => true
    elsif Object.const_defined?(:GetText)
      set_default_options :tr_fn => '::GetText._',
                          :tr => true
    elsif Object.const_defined?(:FastGettext)
      set_default_options :tr_fn => '::FastGettext::Translation._',
                          :tr => true
    end

    def self.i18n_text(text)
      I18n.t!(text)
    rescue I18n::MissingTranslationData
      text
    end

    def self.i18n_key(text)
      key = text.parameterize.underscore
      I18n.t!(key)
    rescue I18n::MissingTranslationData
      text
    end

    def call(exp)
      if options[:tr]
        super
      else
        exp
      end
    end

    def initialize(opts)
      super
      case options[:tr_mode]
      when :static
        @translator = StaticTranslator.new(options)
      when :dynamic
        @translator = DynamicTranslator.new(options)
      else
        raise "Invalid translator mode #{options[:tr_mode].inspect}"
      end
    end

    def on_slim_text(exp)
      [:slim, :text, @translator.call(exp)]
    end

    private

    class StaticTranslator < Filter
      def initialize(opts)
        super
        @translate = eval("proc {|string| #{options[:tr_fn]}(string) }")
      end

      def call(exp)
        @text, @captures = '', []
        result = compile(exp)

        text = @translate.call(@text)
        while text =~ /%(\d+)/
          result << [:static, $`] << @captures[$1.to_i - 1]
          text = $'
        end
        result << [:static, text]
      end

      def on_static(text)
        @text << text
        [:multi]
      end

      def on_slim_output(escape, code, content)
        @captures << [:slim, :output, escape, code, content]
        @text << "%#{@captures.size}"
        [:multi]
      end
    end

    class DynamicTranslator < Filter
      def call(exp)
        @captures_count, @captures_var, @text = 0, unique_name, ''

        result = compile(exp)

        if @captures_count > 0
          result.insert(1, [:code, "#{@captures_var}=[]"])
          result << [:slim, :output, false, "#{options[:tr_fn]}(#{@text.inspect}).gsub(/%(\\d+)/) { #{@captures_var}[$1.to_i-1] }", [:multi]]
        else
          result << [:slim, :output, false, "#{options[:tr_fn]}(#{@text.inspect})", [:multi]]
        end
      end

      def on_static(text)
        @text << text
        [:multi]
      end

      def on_slim_output(escape, code, content)
        @captures_count += 1
        @text << "%#{@captures_count}"
        [:capture, "#{@captures_var}[#{@captures_count-1}]", [:slim, :output, escape, code, content]]
      end
    end
  end
end

# Insert plugin filter into Slim engine chain
Slim::Engine.before(Slim::EndInserter, Slim::Translator, :tr, :tr_fn, :tr_mode)
