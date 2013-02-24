require 'slim'
require 'slim/smart/filter'
require 'slim/smart/escaper'

# Enable implicit text recognition by default.
Slim::Engine.set_default_options :implicit => true
    
# Insert plugin filters into Slim engine chain
Slim::Engine.after(Slim::Parser, Slim::Smart::Filter, :smart_text, :smart_text_end_chars, :smart_text_begin_chars)
Slim::Engine.after(Slim::Interpolation, Slim::Smart::Escaper, :smart_text_escaping)
