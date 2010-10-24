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
    haml        = Haml::Engine.new(tpl_haml)
    haml_ugly   = Haml::Engine.new(tpl_haml, :ugly => true)
    slim        = Slim::Template.new { tpl_slim }

    bench('erb')                  { ERB.new(tpl_erb).result(eview) }
    bench('erubis')               { Erubis::Eruby.new(tpl_erb).result(eview) }
    bench('fast erubis')          { Erubis::Eruby.new(tpl_erb).result(eview) }
    bench('slim')                 { Slim::Template.new { tpl_slim }.render(view) }
    bench('haml')                 { Haml::Engine.new(tpl_haml).render(view) }
    bench('haml ugly')            { Haml::Engine.new(tpl_haml, :ugly => true).render(view) }
    bench('erb (cached)')         { erb.result(eview) }
    bench('erubis (cached)')      { erubis.result(eview) }
    bench('fast erubis (cached)') { fast_erubis.result(eview) }
    bench('slim (cached)')        { slim.render(view) }
    bench('haml (cached)')        { haml.render(view) }
    bench('haml ugly (cached)')   { haml_ugly.render(view) }
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
