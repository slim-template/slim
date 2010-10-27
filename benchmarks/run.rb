#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'), File.join(File.dirname(__FILE__), 'src'))

require 'slim'
require 'complex_view'

require 'benchmark'
require 'ostruct'
require 'erubis'
require 'erb'
require 'haml'

class SlimBenchmarks
  def initialize(iterations)
    @iterations = (iterations || 1000).to_i
    @benches    = []

    tpl_erb  = File.read(File.dirname(__FILE__) + '/src/complex.erb')
    tpl_haml = File.read(File.dirname(__FILE__) + '/src/complex.haml')
    tpl_slim = File.read(File.dirname(__FILE__) + '/src/complex.slim')

    view  = ComplexView.new
    eview = OpenStruct.new(:header => view.header, :item => view.item).instance_eval{ binding }

    erb         = ERB.new(tpl_erb)
    erubis      = Erubis::Eruby.new(tpl_erb)
    fast_erubis = Erubis::FastEruby.new(tpl_erb)
    haml        = Haml::Engine.new(tpl_haml, :format => :html5)
    haml_ugly   = Haml::Engine.new(tpl_haml, :format => :html5, :ugly => true)
    slim        = Slim::Template.new { tpl_slim }

    haml.def_method(view, :run_haml)
    haml_ugly.def_method(view, :run_haml_ugly)
    view.instance_eval(<<-RUBY)
      def run_erb; #{erb.src}; end
      def run_erubis; #{erubis.src}; end
      def run_fast_erubis; #{fast_erubis.src}; end
      def run_slim; #{slim.precompiled_template}; end
    RUBY

    bench('erb')         { ERB.new(tpl_erb).result(eview) }
    bench('erubis')      { Erubis::Eruby.new(tpl_erb).result(eview) }
    bench('fast erubis') { Erubis::Eruby.new(tpl_erb).result(eview) }
    bench('slim')        { Slim::Template.new { tpl_slim }.render(view) }
    bench('haml')        { Haml::Engine.new(tpl_haml, :format => :html5).render(view) }
    bench('haml ugly')   { Haml::Engine.new(tpl_haml, :format => :html5, :ugly => true).render(view) }

    bench('erb (compiled)')         { erb.result(eview) }
    bench('erubis (compiled)')      { erubis.result(eview) }
    bench('fast erubis (compiled)') { fast_erubis.result(eview) }
    bench('slim (compiled)')        { slim.render(view) }
    bench('haml (compiled)')        { haml.render(view) }
    bench('haml ugly (compiled)')   { haml_ugly.render(view) }

    bench('erb (cached)')         { view.run_erb }
    bench('erubis (cached)')      { view.run_erubis }
    bench('fast erubis (cached)') { view.run_fast_erubis }
    bench('slim (cached)')        { view.run_slim }
    bench('haml (cached)')        { view.run_haml }
    bench('haml ugly (cached)')   { view.run_haml_ugly }
  end

  def run
    puts "#{@iterations} Iterations"
    Benchmark.bmbm do |x|
      @benches.each do |name, block|
        x.report name.to_s do
          @iterations.to_i.times { block.call }
        end
      end
    end
  end

  def bench(name, &block)
    @benches.push([name, block])
  end
end

SlimBenchmarks.new(ARGV[0]).run
