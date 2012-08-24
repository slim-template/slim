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
      raise "Invalid translator mode #{options[:tr_mode].inspect}" unless [:static, :dynamic].include?(options[:tr_mode])
      @translate = eval("proc {|string| #{options[:tr_fn]}(string) }") if options[:tr_mode] == :static
    end

    def on_slim_text(exp)
      @flattener ||= Temple::Filters::MultiFlattener.new
      exp = @flattener.call(exp)
      exps = (exp[0] == :multi ? exp[1..-1] : [exp])

      if options[:tr_mode] == :dynamic
        translate_dynamic(exps)
      else
        translate_static(exps)
      end
    end

    private

    def translate_static(exps)
      result, text, captures = [:multi], '', []
      exps.each do |exp|
        if exp.first == :static
          text << exp.last
        elsif exp[0] == :slim && exp[1] == :output
          captures << exp
          text << "%#{captures.size}"
        elsif exp.first == :newline
          result << [:newline]
        else
          raise "Invalid expression #{exp.inspect}"
        end
      end

      text = @translate.call(text)
      while text =~ /%(\d+)/
        result << [:static, $`] << captures[$1.to_i - 1]
        text = $'
      end
      result << [:static, text]
    end

    def translate_dynamic(exps)
      result, text, captures_var, captures_count = [:multi], '', unique_name, 0
      exps.each do |exp|
        if exp.first == :newline
          result << [:newline]
        elsif exp[0] == :slim && exp[1] == :output
          result << [:capture, "#{captures_var}[#{captures_count}]", exp]
          captures_count += 1
          text << "%#{captures_count}"
        elsif exp.first == :static
          text << exp.last
        else
          raise "Invalid expression #{exp.inspect}"
        end
      end
      if captures_count > 0
        result.insert(1, [:code, "#{captures_var}=[]"])
        result << [:slim, :output, false, "#{options[:tr_fn]}(#{text.inspect}).gsub(/%(\\d+)/) { #{captures_var}[$1.to_i-1] }", [:multi]]
      else
        result << [:slim, :output, false, "#{options[:tr_fn]}(#{text.inspect})", [:multi]]
      end
    end
  end
end

# Insert plugin filter into Slim engine chain
Slim::Engine.before(Slim::EndInserter, Slim::Translator, :tr, :tr_fn, :tr_mode)
