require 'slim'

module Slim
  # Handles inlined includes
  # @api private
  class Include < Slim::Filter
    define_options :file, :include_dirs => [Dir.pwd, '.']

    CONTENT_RULE = Temple::Grammar::Rule([:slim, :text, [:multi, [:slim, :interpolate, String]]])

    def on_html_tag(tag, attributes, content)
      if tag == 'include'
        raise ArgumentError, "Invalid include statement" unless attributes == [:html, :attrs] && CONTENT_RULE === content
        name = content[2][1][2]
        name << '.slim' if name !~ /\.slim\Z/i
        current_dir = File.dirname(File.expand_path(options[:file]))
        file = options[:include_dirs].map {|dir| File.expand_path(File.join(dir, name), current_dir) }.find {|file| File.exists?(file) }
        raise "'#{name}' not found in #{options[:include_dirs].inspect}" unless file
        content = File.read(name)
        Thread.current[:slim_engine].call(content)
      else
        [:html, :tag, tag, attributes, content]
      end
    end
  end

  class Engine
    after Slim::Parser, Slim::Include, :file, :include_dirs
    after Slim::Include, :Stop do |exp|
      throw :stop, exp if Thread.current[:slim_level] > 1
      exp
    end

    alias old_call call
    def call(input)
      Thread.current[:slim_engine] = self
      Thread.current[:slim_level] ||= 0
      Thread.current[:slim_level] += 1
      catch(:stop) { old_call(input) }
    ensure
      Thread.current[:slim_engine] = nil if (Thread.current[:slim_level] -= 1) == 0
    end
  end
end
