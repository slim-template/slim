module Slim
  class Translator < Filter
    set_default_options :tr_mode => :dynamic

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
      result = [:multi]

      text, captures = '', []
      exps.each do |exp|
        if exp.first == :static
          text << exp.last
        elsif exp.first == :newline
          result << exp
        else
          captures << exp
          text << "%#{captures.size}"
        end
      end

      if options[:tr_mode] == :dynamic
        if captures.empty?
          result << [:slim, :output, false, "#{options[:tr_fn]}(#{text.inspect})", [:multi]]
        else
          captures_var = unique_name
          result << [:code, "#{captures_var}=[]"]
          captures.each_with_index {|exp, i| result << [:capture, "#{captures_var}[#{i}]", exp] }
          result << [:slim, :output, false, "#{options[:tr_fn]}(#{text.inspect}).gsub(/%(\\d+)/) { #{captures_var}[$1.to_i-1] }", [:multi]]
        end
      else
        text = @translate.call(text).split(/%\d+/)
        text.each_with_index do |s, i|
          result << [:static, s]
          result << captures[i] if i < captures.size
        end
      end
      result
    end
  end
end

# Insert plugin filter into Slim engine chain
Slim::Engine.before(Slim::EndInserter, Slim::Translator, :tr, :tr_fn, :tr_mode)
