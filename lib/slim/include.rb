require 'slim'

module Slim
  # Handles inlined includes
  #
  # Slim files are compiled, non-Slim files are included as text with `#{interpolation}`
  #
  # @api private
  class Include < Slim::Filter
    define_options :file, :include_dirs => [Dir.pwd, '.']

    CONTENT_RULE = Temple::Grammar::Rule [:slim, :text, [:multi, [:slim, :interpolate, String]]]

    def on_html_tag(tag, attributes, content)
      return super if tag != 'include'
      raise ArgumentError, 'Invalid include statement' unless attributes == [:html, :attrs] && CONTENT_RULE === content
      name = content[2][1][2]
      unless file = find_file(name)
        name = "#{name}.slim" if name !~ /\.slim\Z/i
        file = find_file(name)
      end
      raise "'#{name}' not found in #{options[:include_dirs].join(':')}" unless file
      content = File.read(name)
      if file =~ /\.slim\Z/i
        Thread.current[:slim_include_engine].call(content)
      else
        [:slim, :interpolate, content]
      end
    end

    protected

    def find_file(name)
      current_dir = File.dirname(File.expand_path(options[:file]))
      options[:include_dirs].map {|dir| File.expand_path(File.join(dir, name), current_dir) }.find {|file| File.file?(file) }
    end
  end

  class Engine
    after Slim::Parser, Slim::Include, :file, :include_dirs
    after Slim::Include, :stop do |exp|
      throw :stop, exp if Thread.current[:slim_include_level] > 1
      exp
    end

    alias call_without_include call
    def call(input)
      Thread.current[:slim_include_engine] = self
      Thread.current[:slim_include_level] ||= 0
      Thread.current[:slim_include_level] += 1
      catch(:stop) { call_without_include(input) }
    ensure
      Thread.current[:slim_include_engine] = nil if (Thread.current[:slim_include_level] -= 1) == 0
    end
  end
end
