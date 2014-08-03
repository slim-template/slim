require 'slim'
require 'slim/smart/filter'
require 'slim/smart/escaper'
require 'slim/smart/parser'

Slim::Engine.replace(Slim::Parser, Slim::Smart::Parser, :file, :tabsize, :shortcut, :default_tag, :attr_delims, :attr_list_delims, :code_attr_delims, :implicit_text)
Slim::Engine.after(Slim::Smart::Parser, Slim::Smart::Filter, :smart_text, :smart_text_end_chars, :smart_text_begin_chars)
Slim::Engine.after(Slim::Interpolation, Slim::Smart::Escaper, :smart_text_escaping)
