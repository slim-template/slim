require 'slim'
require 'optparse'

module Slim
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
      opts.on('-s', '--stdin', :NONE, 'Read input from standard input instead of an input file') do
        @options[:input] = $stdin
      end

      opts.on('--trace', :NONE, 'Show a full traceback on error') do
        @options[:trace] = true
      end

      opts.on('-c', '--compile', :NONE, 'Compile only but do not run') do
        @options[:compile] = true
      end

      opts.on('-r', '--rails', :NONE, 'Generate rails compatible code (combine with -c)') do
        @options[:rails] = true
      end

      opts.on('-S', '--sections', :NONE, 'Logic-less sections mode') do
        @options[:sections] = true
      end

      opts.on('-p', '--pretty', :NONE, 'Produce pretty html') do
        @options[:pretty] = true
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
        @options[:output].puts(Slim::Engine.new(:file => @options[:file],
                                                :pretty => @options[:pretty],
                                                :sections => @options[:sections],
                                                :disable_capture => @options[:rails],
                                                :generator => @options[:rails] ?
                                                Temple::Generators::RailsOutputBuffer :
                                                Temple::Generators::ArrayBuffer).call(@options[:input].read))
      else
        @options[:output].puts(Slim::Template.new(@options[:file],
                                                  :pretty => @options[:pretty],
                                                  :sections => @options[:sections]) { @options[:input].read }.render)
      end
    end
  end
end
