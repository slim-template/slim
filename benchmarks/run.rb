#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/src/helper'
require File.dirname(__FILE__) + '/src/complex_view'
require File.dirname(__FILE__) + '/../lib/slim'

require 'ostruct'
require 'erubis'
require 'erb'
require 'haml'

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
slim        = Slim::Engine.new(tpl_slim)

bench('erb')                  { ERB.new(tpl_erb).result(eview) }
bench('erubis')               { Erubis::Eruby.new(tpl_erb).result(eview) }
bench('fast erubis')          { Erubis::Eruby.new(tpl_erb).result(eview) }
bench('slim')                 { Slim::Engine.new(tpl_slim).render(view) }
bench('haml')                 { Haml::Engine.new(tpl_haml).render(view) }
bench('haml ugly')            { Haml::Engine.new(tpl_haml, :ugly => true).render(view) }
bench('erb (cached)')         { erb.result(eview) }
bench('erubis (cached)')      { erubis.result(eview) }
bench('fast erubis (cached)') { fast_erubis.result(eview) }
bench('slim (cached)')        { slim.render(view) }
bench('haml (cached)')        { haml.render(view) }
bench('haml ugly (cached)')   { haml_ugly.render(view) }
