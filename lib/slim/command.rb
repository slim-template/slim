require 'slim'
require 'optparse'

module Slim
  Engine.set_default_options :pretty => false

  # Slim commandline interface
  # @api private
  class Command
    def initialize(args)
      @args = args
      @options = {}
    end

    # Run command
    def run
      @opts = OptionParser.new(&method(:set_opts))
      @opts.parse!(@args)
      process
      exit 0
    rescue Exception => ex
      raise ex if @options[:trace] || SystemExit === ex
      $stderr.print "#{ex.class}: " if ex.class != RuntimeError
      $stderr.puts ex.message
      $stderr.puts '  Use --trace for backtrace.'
      exit 1
    end

    private

    # Configure OptionParser
    def set_opts(opts)
      opts.on('-s', '--stdin', 'Read input from standard input instead of an input file') do
        @options[:input] = $stdin
      end

      opts.on('--trace', 'Show a full traceback on error') do
        @options[:trace] = true
      end

      opts.on('-c', '--compile', 'Compile only but do not run') do
        @options[:compile] = true
      end

      opts.on('-r', '--rails', 'Generate rails compatible code (Implies --compile)') do
        Engine.set_default_options :disable_capture => true, :generator => Temple::Generators::RailsOutputBuffer
        @options[:compile] = true
      end

      opts.on('-t', '--translator', 'Enable translator plugin') do
        require 'slim/translator'
      end

      opts.on('-l', '--logic-less', 'Enable logic less plugin') do
        require 'slim/logic_less'
      end

      opts.on('-p', '--pretty', 'Produce pretty html') do
        Engine.set_default_options :pretty => true
      end

      opts.on('-o', '--option [NAME=CODE]', String, 'Set slim option') do |str|
        parts = str.split('=', 2)
        Engine.default_options[parts.first.to_sym] = eval(parts.last)
      end

      opts.on_tail('-h', '--help', 'Show this message') do
        puts opts
        exit
      end

      opts.on_tail('-v', '--version', 'Print version') do
        puts "Slim #{Slim::VERSION}"
        exit
      end
    end

    # Process command
    def process
      args = @args.dup
      unless @options[:input]
        file = args.shift
        if file
          @options[:file] = file
          @options[:input] = File.open(file, 'r')
        else
          @options[:file] = 'STDIN'
          @options[:input] = $stdin
        end
      end

      unless @options[:output]
        file = args.shift
        @options[:output] = file ? File.open(file, 'w') : $stdout
      end

      if @options[:compile]
        @options[:output].puts(Slim::Engine.new(:file => @options[:file]).call(@options[:input].read))
      else
        @options[:output].puts(Slim::Template.new(@options[:file]) { @options[:input].read }.render)
      end
    end
  end
end
