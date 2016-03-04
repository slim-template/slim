#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'), File.dirname(__FILE__))

require 'slim'
require 'context'

require 'benchmark/ips'
require 'tilt'
require 'erubis'
require 'erb'
require 'haml'

class SlimBenchmarks
  def initialize(slow)
    @benches   = Hash.new { |h, k| h[k] = [] }

    @erb_code  = File.read(File.dirname(__FILE__) + '/view.erb')
    @haml_code = File.read(File.dirname(__FILE__) + '/view.haml')
    @slim_code = File.read(File.dirname(__FILE__) + '/view.slim')

    init_compiled_benches
    init_tilt_benches
    init_parsing_benches if slow
  end

  def init_compiled_benches
    haml_pretty = Haml::Engine.new(@haml_code, format: :html5, escape_attrs: false)
    haml_ugly   = Haml::Engine.new(@haml_code, format: :html5, ugly: true, escape_attrs: false)

    context  = Context.new

    haml_pretty.def_method(context, :run_haml_pretty)
    haml_ugly.def_method(context, :run_haml_ugly)
    context.instance_eval %{
      def run_erb; #{ERB.new(@erb_code).src}; end
      def run_erubis; #{Erubis::Eruby.new(@erb_code).src}; end
      def run_temple_erb; #{Temple::ERB::Engine.new.call @erb_code}; end
      def run_fast_erubis; #{Erubis::FastEruby.new(@erb_code).src}; end
      def run_slim_pretty; #{Slim::Engine.new(pretty: true).call @slim_code}; end
      def run_slim_ugly; #{Slim::Engine.new.call @slim_code}; end
    }

    bench(:compiled, 'erb')         { context.run_erb }
    bench(:compiled, 'erubis')      { context.run_erubis }
    bench(:compiled, 'fast erubis') { context.run_fast_erubis }
    bench(:compiled, 'temple erb')  { context.run_temple_erb }
    bench(:compiled, 'slim pretty') { context.run_slim_pretty }
    bench(:compiled, 'slim ugly')   { context.run_slim_ugly }
    bench(:compiled, 'haml pretty') { context.run_haml_pretty }
    bench(:compiled, 'haml ugly')   { context.run_haml_ugly }
  end

  def init_tilt_benches
    tilt_erb         = Tilt::ERBTemplate.new { @erb_code }
    tilt_erubis      = Tilt::ErubisTemplate.new { @erb_code }
    tilt_temple_erb  = Temple::ERB::Template.new { @erb_code }
    tilt_haml_pretty = Tilt::HamlTemplate.new(format: :html5) { @haml_code }
    tilt_haml_ugly   = Tilt::HamlTemplate.new(format: :html5, ugly: true) { @haml_code }
    tilt_slim_pretty = Slim::Template.new(pretty: true) { @slim_code }
    tilt_slim_ugly   = Slim::Template.new { @slim_code }

    context  = Context.new

    bench(:tilt, 'erb')         { tilt_erb.render(context) }
    bench(:tilt, 'erubis')      { tilt_erubis.render(context) }
    bench(:tilt, 'temple erb')  { tilt_temple_erb.render(context) }
    bench(:tilt, 'slim pretty') { tilt_slim_pretty.render(context) }
    bench(:tilt, 'slim ugly')   { tilt_slim_ugly.render(context) }
    bench(:tilt, 'haml pretty') { tilt_haml_pretty.render(context) }
    bench(:tilt, 'haml ugly')   { tilt_haml_ugly.render(context) }
  end

  def init_parsing_benches
    context  = Context.new
    context_binding = context.instance_eval { binding }

    bench(:parsing, 'erb')         { ERB.new(@erb_code).result(context_binding) }
    bench(:parsing, 'erubis')      { Erubis::Eruby.new(@erb_code).result(context_binding) }
    bench(:parsing, 'fast erubis') { Erubis::FastEruby.new(@erb_code).result(context_binding) }
    bench(:parsing, 'temple erb')  { Temple::ERB::Template.new { @erb_code }.render(context) }
    bench(:parsing, 'slim pretty') { Slim::Template.new(pretty: true) { @slim_code }.render(context) }
    bench(:parsing, 'slim ugly')   { Slim::Template.new { @slim_code }.render(context) }
    bench(:parsing, 'haml pretty') { Haml::Engine.new(@haml_code, format: :html5).render(context) }
    bench(:parsing, 'haml ugly')   { Haml::Engine.new(@haml_code, format: :html5, ugly: true).render(context) }
  end

  def run
    @benches.each do |group_name, group_benches|
      puts "Running #{group_name} benchmarks:"

      Benchmark.ips do |x|
        group_benches.each do |name, block|
          x.report("#{group_name} #{name}", &block)
        end

        x.compare!
      end
    end

    puts "
Compiled benchmark: Template is parsed before the benchmark and
    generated ruby code is compiled into a method.
    This is the fastest evaluation strategy because it benchmarks
    pure execution speed of the generated ruby code.

Compiled Tilt benchmark: Template is compiled with Tilt, which gives a more
    accurate result of the performance in production mode in frameworks like
    Sinatra, Ramaze and Camping. (Rails still uses its own template
    compilation.)

Parsing benchmark: Template is parsed every time.
    This is not the recommended way to use the template engine
    and Slim is not optimized for it. Activate this benchmark with 'rake bench slow=1'.

Temple ERB is the ERB implementation using the Temple framework. It shows the
overhead added by the Temple framework compared to ERB.
"
  end

  def bench(group, name, &block)
    @benches[group].push([name, block])
  end
end

SlimBenchmarks.new(ENV['slow']).run
