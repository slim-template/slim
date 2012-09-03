# Slim


[![Build Status](https://secure.travis-ci.org/stonean/slim.png?branch=master)](http://travis-ci.org/stonean/slim) [![Dependency Status](https://gemnasium.com/stonean/slim.png?travis)](https://gemnasium.com/stonean/slim) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/stonean/slim)

Slim is a template language whose goal is to reduce the view syntax to the essential parts without becoming cryptic.

## Introduction

### What is Slim?

Slim is a fast, lightweight templating engine with support for __Rails 3__. It has been heavily tested on all major ruby implementations. We use
continous integration (travis-ci).

Slim's core syntax is guided by one thought: "What's the minimum required to make this work".

As more people have contributed to Slim, there have been syntax additions influenced from their use of [Haml](https://github.com/nex3/haml) and [Jade](https://github.com/visionmedia/jade).  The Slim team is open to these additions because we know beauty is in the eye of the beholder.

Slim uses [Temple](https://github.com/judofyr/temple) for parsing/compilation and is also integrated into [Tilt](https://github.com/rtomayko/tilt), so it can be used together with [Sinatra](https://github.com/sinatra/sinatra) or plain [Rack](https://github.com/rack/rack).

The architecture of Temple is very flexible and allows the extension of the parsing and compilation process without monkey-patching. This is used
by the logic-less plugin and the translator plugin which provides I18n.

### Why use Slim?

Within the Rails community, _Erb_ and _Haml_ are without doubt the two most popular templating engines. However, _Erb_'s syntax is cumbersome and _Haml_'s syntax can be quite cryptic to the uninitiated.

Slim was born to bring a minimalist syntax approach with speed. If people chose not to use Slim, it would not be because of speed.

___Yes, Slim is speedy!___ Benchmarks are provided at the end of this README file. Don't trust the numbers? That's as it should be. Therefore we provide a benchmark rake task so you could test it yourself (`rake bench`).

### How to start?

Install Slim as a gem:

    gem install slim

Include Slim in your Gemfile with `gem 'slim'` or require it with `require 'slim'`. That's it! Now, just use the .slim extension and you're good to go.

### Syntax example

Here's a quick example to demonstrate what a Slim template looks like:

    doctype html
    html
      head
        title Slim Examples
        meta name="keywords" content="template language"
        meta name="author" content=author
        link rel="icon" type="image/png" href=file_path("favicon.png")
        javascript:
          alert('Slim supports embedded javascript!')

      body
        h1 Markup examples

        #content
          p This example shows you how a basic Slim file looks like.

        = yield

        - if items.any?
          table#items
            - for item in items do
              tr
                td.name = item.name
                td.price = item.price
        - else
          p No items found

        #footer
          = render 'footer'
          | Copyright &copy; #{year} #{author}

Indentation matters, but the indentation depth can be chosen as you like. If you want to first indent 2 spaces, then 5 spaces, it's your choice. To nest markup you only need to indent by one space, the rest is gravy.

## Line indicators

### Text `|`

The pipe tells Slim to just copy the line. It essentially escapes any processing.
Each following line that is indented greater than the backtick is copied over.

    body
      p
        |
          This is a test of the text block.

  The parsed result of the above:

    <body><p>This is a test of the text block.</p></body>

  The left margin is set at the indent of the backtick + one space.
  Any additional spaces will be copied over.

    body
      p
        |  This line is on the left margin.
            This line will have one space in front of it.
              This line will have two spaces in front of it.
                And so on...

### Text with trailing space `'`

The single quote tells Slim to copy the line (similar to |), but makes sure that a single trailing space is appended.

### Control code `-`

The dash denotes control code.  Examples of control code are loops and conditionals. `end` is forbidden behind `-`. Blocks are defined only by indentation.
If your ruby code needs to use multiple lines, append a `\` at the end of the lines.

### Dynamic output `=`

The equal sign tells Slim it's a Ruby call that produces output to add to the buffer. If your ruby code needs to use multiple lines, append a `\` at the end of the lines, for example:

    = javascript_include_tag \
       "jquery", \
       "application"

### Output with trailing white space `='`

Same as the single equal sign (`=`), except that it adds a trailing whitespace.

### Output without HTML escaping `==`

Same as the single equal sign (`=`), but does not go through the `escape_html` method.

### Output without HTML escaping and trailing ws `=='`

Same as the double equal sign (`==`), except that it adds a trailing whitespace.

### Code comment `/`

Use the forward slash for code comments - anything after it won't get displayed in the final render. Use `/` for code comments and `/!` for html comments

    body
      p
        / This line won't get displayed.
          Neither does this line.
        /! This will get displayed as html comments.

  The parsed result of the above:

    <body><p><!--This will get displayed as html comments.--></p></body>

### HTML comment `/!`

Use the forward slash immediately followed by an exclamation mark for html comments (` <!-- --> `).

### IE conditional comment `/![IE]`

    /[ if IE ]
        p Get a better browser.

    <!--[if IE]><p>Get a better browser.</p><![endif]-->

## HTML tags

### Doctype tag

The doctype tag is a special tag which can be used to generate the complex doctypes in a very simple way.

XML VERSION

    doctype xml
      <?xml version="1.0" encoding="utf-8" ?>

    doctype xml ISO-8859-1
      <?xml version="1.0" encoding="iso-8859-1" ?>

XHTML DOCTYPES

    doctype html
      <!DOCTYPE html>

    doctype 5
      <!DOCTYPE html>

    doctype 1.1
      <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN"
        "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">

    doctype strict
      <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

    doctype frameset
      <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">

    doctype mobile
      <!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN"
        "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">

    doctype basic
      <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN"
        "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">

    doctype transitional
      <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

HTML 4 DOCTYPES

    doctype strict
      <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"
        "http://www.w3.org/TR/html4/strict.dtd">

    doctype frameset
      <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN"
        "http://www.w3.org/TR/html4/frameset.dtd">

    doctype transitional
      <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
        "http://www.w3.org/TR/html4/loose.dtd">

### Closed tags (trailing `/`)

You can close tags explicitly by appending a trailing `/`.

    img src="image.png"/

Note, that this is usually not necessary since the standard html
tags (img, br, ...) are closed automatically.

### Inline tags

Sometimes you may want to be a little more compact and inline the tags.

    ul
      li.first: a href="/a" A link
      li: a href="/b" B link

For readability, don't forget you can wrap the attributes.

    ul
      li.first: a[href="/a"] A link
      li: a[href="/b"] B link

### Text content

Either start on the same line as the tag

    body
      h1 id="headline" Welcome to my site.

Or nest it.  You must use a pipe or a backtick to escape processing

    body
      h1 id="headline"
        | Welcome to my site.

### Dynamic content (`=` and `==`)

Can make the call on the same line

    body
      h1 id="headline" = page_headline

Or nest it.

    body
      h1 id="headline"
        = page_headline

### Attributes

You write attributes directly after the tag. For normal text attributes you must use double `"` or single quotes `'` (Quoted attributes).

    a href="http://slim-lang.com" title='Slim Homepage' Goto the Slim homepage

You can use text interpolation in the quoted attributes.

#### Attributes wrapper

If a delimiter makes the syntax more readable for you,
you can use the characters `{...}`, `(...)`, `[...]` to wrap the attributes.

    body
      h1(id="logo") = page_logo
      h2[id="tagline" class="small tagline"] = page_tagline


If you wrap the attributes, you can spread them across multiple lines:

    h2[id="tagline"
       class="small tagline"] = page_tagline

#### Quoted attributes

Example:

    a href="http://slim-lang.com" title='Slim Homepage' Goto the Slim homepage

You can use text interpolation in the quoted attributes:

    a href="http://#{url}" Goto the #{url}

#### Ruby attributes

Write the ruby code directly after the `=`. If the code contains spaces you have to wrap
the code into parentheses `(...)`, `{...}` or `[...]`. The code in the parentheses will be evaluated.

    body
      table
        - for user in users do
          td id="user_#{user.id}" class=user.role
            a href=user_action(user, :edit) Edit #{user.name}
            a href={path_to_user user} = user.name

Use == if you want to disable escaping in the attribute.

#### Boolean attributes

The attribute values `true`, `false` and `nil` are interpreted
as booleans. If you use the attribut wrapper you can omit the attribute assigment

    input type="text" disabled="disabled"
    input type="text" disabled=true
    input(type="text" disabled)

    input type="text"
    input type="text" disabled=false
    input type="text" disabled=nil

#### Splat attributes `*`

The splat shortcut allows you turn a hash in to attribute/value pairs

    .card*{'data-url'=>place_path(place), 'data-id'=>place.id} = place.name
    .card *method_which_returns_hash = place.name

    <div class="card" data-id="1234" data-url="/place/1234">Slim's house</div>

#### ID shortcut `#` and class shortcut `.`

Similarly to Haml, you can specify the `id` and `class` attributes in the following shortcut form

    body
      h1#headline
        = page_headline
      h2#tagline.small.tagline
        = page_tagline
      .content
        = show_content

This is the same as

    body
      h1 id="headline"
        = page_headline
      h2 id="tagline" class="small tagline"
        = page_tagline
      div class="content"
        = show_content

#### Attribute shortcuts

You can define custom shortcuts (Similar to `#` for id and `.` for class).

In this example we add `@` to create a shortcut for the role attribute.

    Slim::Engine.set_default_options :shortcut => {'@' => 'role', '#' => 'id', '.' => 'class'}

We can use it in Slim code like this

    .person@admin = person.name

which renders to

    <div class="person" role="admin">Daniel</div>

## Text interpolation

Use standard Ruby interpolation. The text will be html escaped by default.

    body
      h1 Welcome #{current_user.name} to the show.
      | Unescaped #{{content}} is also possible.

To escape the interpolation (i.e. render as is)

    body
      h1 Welcome \#{current_user.name} to the show.

## Embedded engines (Markdown, ...)

Thanks to Tilt, Slim has impressive support for embedding other template engines.

Examples:

    coffee:
      square = (x) -> x * x

    markdown:
      #Header
        Hello from #{"Markdown!"}
        Second Line!

Supported engines:

<table>
<thead style="font-weight:bold"><tr><td>Engine</td><td>Filter</td><td>Required libraries</td><td>Type</td><td>Description</td></tr></thead>
<tbody>
<tr><td>Ruby</td><td>ruby:</td><td>none</td><td>Shortcut</td><td>Shortcut to embed ruby code</td></tr>
<tr><td>Javascript</td><td>javascript:</td><td>none</td><td>Shortcut</td><td>Shortcut to embed javascript code and wrap in script tag</td></tr>
<tr><td>CSS</td><td>css:</td><td>none</td><td>Shortcut</td><td>Shortcut to embed css code and wrap in style tag</td></tr>
<tr><td>Sass</td><td>sass:</td><td>sass</td><td>Compile time</td><td>Embed sass code and wrap in style tag</td></tr>
<tr><td>Scss</td><td>scss:</td><td>sass</td><td>Compile time</td><td>Embedd scss code and wrap in style tag</td></tr>
<tr><td>LessCSS</td><td>less:</td><td>less</td><td>Compile time</td><td>Embed less css code and wrap in style tag</td></tr>
<tr><td>Stylus</td><td>styl:</td><td>styl</td><td>Compile time</td><td>Embed stylus css code and wrap in style tag</td></tr>
<tr><td>CoffeeScript</td><td>coffee:</td><td>coffee-script (+node coffee)</td><td>Compile time</td><td>Compile coffee script code and wrap in script tag</td></tr>
<tr><td>RDiscount</td><td>markdown:</td><td>rdiscount/kramdown</td><td>Compile time + Interpolation</td><td>Compile markdown code and interpolate #\{variables} in text</td></tr>
<tr><td>RedCloth</td><td>textile:</td><td>redcloth</td><td>Compile time + Interpolation</td><td>Compile textile code and interpolate #\{variables} in text</td></tr>
<tr><td>Creole</td><td>creole:</td><td>creole</td><td>Compile time + Interpolation</td><td>Compile creole code and interpolate #\{variables} in text</td></tr>
<tr><td>Wikicloth</td><td>wiki:, mediawiki:</td><td>wikicloth</td><td>Compile time + Interpolation</td><td>Compile wiki code and interpolate #\{variables} in text</td></tr>
<tr><td>RDoc</td><td>rdoc:</td><td>rdoc</td><td>Compile time + Interpolation</td><td>Compile rdoc code and interpolate #\{variables} in text</td></tr>
<tr><td>Builder</td><td>builder:</td><td>builder</td><td>Precompiled</td><td>Embed builder code</td></tr>
<tr><td>Nokogiri</td><td>nokogiri:</td><td>nokogiri</td><td>Precompiled</td><td>Embed nokogiri builder code</td></tr>
<tr><td>ERB</td><td>erb:</td><td>none</td><td>Precompiled</td><td>Embed erb code</td></tr>
<tr><td>Liquid</td><td>liquid:</td><td>liquid</td><td>Runtime</td><td>Embed liquid code (Not recommended, no caching)</td></tr>
<tr><td>Radius</td><td>radius:</td><td>radius</td><td>Runtime</td><td>Embed radius code (Not recommended, no caching)</td></tr>
<tr><td>Markaby</td><td>markaby:</td><td>markaby</td><td>Runtime</td><td>Embed markaby code (Not recommended, no caching)</td></tr>
</tbody>
</table>

The embedded engines can be configured in Slim by setting the options directly on the `Slim::EmbeddedEngine` filter. Example:

    Slim::EmbeddedEngine.default_options[:markdown] = {:auto_ids => false}

## Configuring Slim

Slim and the underlying Temple framework are highly configurable. Unfortunately the way how you configure Slim depends on the compilation mechanism (Rails or Tilt).
It is always possible to set default options. This can be done in Rails' environment files. For instance, in config/environments/development.rb you probably want:

    # Indent html for pretty debugging and do not sort attributes (Ruby 1.8)
    Slim::Engine.set_default_options :pretty => true, :sort_attrs => false

    # Indent html for pretty debugging and do not sort attributes (Ruby 1.9)
    Slim::Engine.set_default_options pretty: true, sort_attrs: false

You can also access the option hash directly:

    Slim::Engine.default_options[:pretty] = true

For developers who know more about Slim and Temple architecture it is possible to override default
options at different positions. Temple uses an inheritance mechanism to allow subclasses to override
options of the superclass. The option priorities are as follows:

    Options passed at engine instantination > Slim::Template > Slim::Engine > Parser/Filter/Generator (e.g Slim::Parser, Slim::Compiler)

It is also possible to set options for superclasses like Temple::Engine. But this will affect all temple template engines then.

    Slim::Engine > Temple::Engine
    Slim::Compiler > Temple::Filter

The following options are exposed by the `Slim::Engine` and can be set with `Slim::Engine.set_default_options`.

<table>
<thead style="font-weight:bold"><tr><td>Type</td><td>Name</td><td>Default</td><td>Purpose</td></tr></thead>
<tbody>
<tr><td>String</td><td>:file</td><td>nil</td><td>Name of parsed file, set automatically by Slim::Template</td></tr>
<tr><td>Integer</td><td>:tabsize</td><td>4</td><td>Number of whitespaces per tab (used by the parser)</td></tr>
<tr><td>String</td><td>:encoding</td><td>"utf-8"</td><td>Set encoding of template</td></tr>
<tr><td>String</td><td>:default_tag</td><td>"div"</td><td>Default tag to be used if tag name is omitted</td></tr>
<tr><td>Hash</td><td>:shortcut</td><td>\{'.' => 'class', '#' => 'id'}</td><td>Attribute shortcuts</td></tr>
<tr><td>String list</td><td>:enable_engines</td><td>nil <i>(All enabled)</i></td><td>List of enabled embedded engines (whitelist)</td></tr>
<tr><td>String list</td><td>:disable_engines</td><td>nil <i>(None disabled)</i></td><td>List of disabled embedded engines (blacklist)</td></tr>
<tr><td>Boolean</td><td>:disable_capture</td><td>false (true in Rails)</td><td>Disable capturing in blocks (blocks write to the default buffer </td></tr>
<tr><td>Boolean</td><td>:disable_escape</td><td>false</td><td>Disable automatic escaping of strings</td></tr>
<tr><td>Boolean</td><td>:use_html_safe</td><td>false (true in Rails)</td><td>Use String#html_safe? from ActiveSupport (Works together with :disable_escape)</td></tr>
<tr><td>Symbol</td><td>:format</td><td>:xhtml</td><td>HTML output format (Possible formats :xhtml, :html4, :html5, :html)</td></tr>
<tr><td>String</td><td>:attr_wrapper</td><td>'"'</td><td>Character to wrap attributes in html (can be ' or ")</td></tr>
<tr><td>Hash</td><td>:attr_delimiter</td><td>\{'class' => ' '}</td><td>Joining character used if multiple html attributes are supplied (e.g. class="class1 class2")</td></tr>
<tr><td>Boolean</td><td>:sort_attrs</td><td>true</td><td>Sort attributes by name</td></tr>
<tr><td>Boolean</td><td>:remove_empty_attrs</td><td>true</td><td>Remove attributes with empty value</td></tr>
<tr><td>Boolean</td><td>:pretty</td><td>false</td><td>Pretty html indenting <b>(This is slower!)</b></td></tr>
<tr><td>String</td><td>:indent</td><td>'  '</td><td>Indentation string</td></tr>
<tr><td>Boolean</td><td>:streaming</td><td>false (true in Rails > 3.1)</td><td>Enable output streaming</td></tr>
<tr><td>Class</td><td>:generator</td><td>Temple::Generators::ArrayBuffer/RailsOutputBuffer</td><td>Temple code generator (default generator generates array buffer)</td></tr>
</tbody>
</table>

Additionally the code generator options can be set (used by the :generator class). The standard generators support the options :buffer and :capture_generator.
There are more options which are supported by the filters which are used by `Slim::Engine` but which are not exposed and are not officially supported. You
have to take a look at the Slim and Temple code for that.

## Plugins

### Logic-less mode

Enable the logic-less plugin with

    require 'slim/logic_less'

<table>
<thead style="font-weight:bold"><tr><td>Type</td><td>Name</td><td>Default</td><td>Purpose</td></tr></thead>
<tbody>
<tr><td>Boolean</td><td>:logic_less</td><td>true</td><td>Enable logic less mode (Enabled if 'slim/logic_less' is required)</td></tr>
<tr><td>String</td><td>:dictionary</td><td>"self"</td><td>Dictionary where variables are looked up</td></tr>
<tr><td>Symbol</td><td>:dictionary_access</td><td>:wrapped</td><td>Dictionary access mode (:string, :symbol, :wrapped)</td></tr>
</tbody>
</table>

#### Variable output

#### Section

#### Inverted section

### Translator

Enable the translator plugin with

    require 'slim/translator'

<table>
<thead style="font-weight:bold"><tr><td>Type</td><td>Name</td><td>Default</td><td>Purpose</td></tr></thead>
<tbody>
<tr><td>Boolean</td><td>:tr</td><td>true</td><td>Enable translator (Enabled if 'slim/translator' is required)</td></tr>
<tr><td>Symbol</td><td>:tr_mode</td><td>:dynamic</td><td>When to translate: :static = at compile time, :dynamic = at runtime</td></tr>
<tr><td>String</td><td>:tr_fn</td><td>Depending on installed translation library</td><td>Translation function, could be '_' for gettext</td></tr>
</tbody>
</table>

## Framework support

### Tilt

Slim uses Tilt to compile the generated code. If you want to use the Slim template directly, you can use the Tilt interface.

    Tilt.new['template.slim'].render(scope)
    Slim::Template.new('template.slim', optional_option_hash).render(scope)
    Slim::Template.new(optional_option_hash) { source }.render(scope)

The optional option hash can have to options which were documented in the section above.

### Sinatra

<pre>
    require 'sinatra'
    require 'slim'
    
    get('/') { slim :index }
    
    __END__
    @@ index
    doctype html
    html
      head
        title Sinatra With Slim
      body
        h1 Slim Is Fun!
</pre>

### Rails

Rails generators are provided by [slim-rails](https://github.com/leogalmeida/slim-rails). slim-rails
is not necessary to use Slim in Rails though. Just install Slim and add it to your Gemfile with `gem 'slim'`.
Then just use the .slim extension and you're good to go.

## Tools

### Syntax Highlighters

There are plugins for various text editors (including the most important ones - Vim, Emacs and Textmate):

* [Vim](https://github.com/bbommarito/vim-slim)
* [Emacs](https://github.com/minad/emacs-slim)
* [Textmate / Sublime Text](https://github.com/fredwu/ruby-slim-tmbundle)
* [Espresso text editor](https://github.com/CiiDub/Slim-Sugar)

### Template Converters (HAML, ERB, ...)

* [Haml2Slim converter](https://github.com/fredwu/haml2slim)
* [HTML2Slim converter](https://github.com/joaomilho/html2slim)
* [ERB2Slim converter](https://github.com/c0untd0wn/erb2slim)

## Testing

### Benchmarks

  *The benchmarks demonstrate that Slim in production mode
   is nearly as fast as ERB. So if you choose not to use Slim it
   is not due to its speed.*

Run the benchmarks with `rake bench`. You can add the option `slow` to
run the slow parsing benchmark which needs more time. You can also increase the number of iterations.

    rake bench slow=1 iterations=1000

<pre>
Linux + Ruby 1.9.3, 1000 iterations
                      user     system      total        real
(1) erb           0.020000   0.000000   0.020000 (  0.016618)
(1) erubis        0.010000   0.000000   0.010000 (  0.013974)
(1) fast erubis   0.010000   0.000000   0.010000 (  0.014625)
(1) temple erb    0.030000   0.000000   0.030000 (  0.024930)
(1) slim pretty   0.030000   0.000000   0.030000 (  0.030838)
(1) slim ugly     0.020000   0.000000   0.020000 (  0.021263)
(1) haml pretty   0.120000   0.000000   0.120000 (  0.121439)
(1) haml ugly     0.110000   0.000000   0.110000 (  0.105082)
(2) erb           0.030000   0.000000   0.030000 (  0.034145)
(2) erubis        0.020000   0.000000   0.020000 (  0.022493)
(2) temple erb    0.040000   0.000000   0.040000 (  0.034921)
(2) slim pretty   0.040000   0.000000   0.040000 (  0.041750)
(2) slim ugly     0.030000   0.000000   0.030000 (  0.030792)
(2) haml pretty   0.140000   0.000000   0.140000 (  0.144159)
(2) haml ugly     0.130000   0.000000   0.130000 (  0.129690)
(3) erb           0.140000   0.000000   0.140000 (  0.140154)
(3) erubis        0.110000   0.000000   0.110000 (  0.110870)
(3) fast erubis   0.100000   0.000000   0.100000 (  0.098940)
(3) temple erb    0.040000   0.000000   0.040000 (  0.036024)
(3) slim pretty   0.040000   0.000000   0.040000 (  0.043326)
(3) slim ugly     0.040000   0.000000   0.040000 (  0.031623)
(3) haml pretty   0.310000   0.000000   0.310000 (  0.317270)
(3) haml ugly     0.250000   0.000000   0.250000 (  0.256257)
(4) erb           0.350000   0.000000   0.350000 (  0.352818)
(4) erubis        0.310000   0.000000   0.310000 (  0.308558)
(4) fast erubis   0.310000   0.000000   0.310000 (  0.308920)
(4) temple erb    0.920000   0.000000   0.920000 (  0.920607)
(4) slim pretty   3.510000   0.000000   3.510000 (  3.513418)
(4) slim ugly     2.940000   0.000000   2.940000 (  2.944823)
(4) haml pretty   2.320000   0.000000   2.320000 (  2.321830)
(4) haml ugly     2.180000   0.000000   2.180000 (  2.179788)

(1) Compiled benchmark. Template is parsed before the benchmark and
    generated ruby code is compiled into a method.
    This is the fastest evaluation strategy because it benchmarks
    pure execution speed of the generated ruby code.

(2) Compiled Tilt benchmark. Template is compiled with Tilt, which gives a more
    accurate result of the performance in production mode in frameworks like
    Sinatra, Ramaze and Camping. (Rails still uses its own template
    compilation.)

(3) Cached benchmark. Template is parsed before the benchmark.
    The ruby code generated by the template engine might be evaluated every time.
    This benchmark uses the standard API of the template engine.

(4) Parsing benchmark. Template is parsed every time.
    This is not the recommended way to use the template engine
    and Slim is not optimized for it. Activate this benchmark with 'rake bench slow=1'.

Temple ERB is the ERB implementation using the Temple framework. It shows the
overhead added by the Temple framework compared to ERB.
</pre>

### Test suite and continous integration

Slim provides an extensive test-suite based on minitest. You can run the tests
with 'rake test' and the rails integration tests with 'rake test:rails'.

Travis-CI is used for continous integration testing: {http://travis-ci.org/#!/stonean/slim}

Slim is working well on all major Ruby implementations:

* Ruby 1.8.7
* Ruby 1.9.2
* Ruby 1.9.3
* Ruby EE
* JRuby
* Rubinius 2.0

## License

This project is released under the MIT license.

## Authors

* [Andrew Stone](https://github.com/stonean)
* [Fred Wu](https://github.com/fredwu)
* [Daniel Mendler](https://github.com/minad)

## Discuss

* [Google Group](http://groups.google.com/group/slim-template)
* IRC Channel #slim-lang on freenode.net

## Related projects

Template compilation framework:

* [Temple](https://github.com/judofyr/slim)

Framework support:

* [Rails 3 generators (slim-rails)](https://github.com/leogalmeida/slim-rails)

Syntax highlighting:

* [Vim](https://github.com/bbommarito/vim-slim)
* [Emacs](https://github.com/minad/emacs-slim)
* [Textmate / Sublime Text](https://github.com/fredwu/ruby-slim-tmbundle)
* [Espresso text editor](https://github.com/CiiDub/Slim-Sugar)

Template Converters (HAML, ERB, ...):

* [Haml2Slim converter](https://github.com/fredwu/haml2slim)
* [HTML2Slim converter](https://github.com/joaomilho/html2slim)
* [ERB2Slim converter](https://github.com/c0untd0wn/erb2slim)

Language ports/Similar languages:

* [Coffee script plugin for Slim](https://github.com/yury/coffee-views)
* [Clojure port of Slim](https://github.com/chaslemley/slim.clj)
* [Hamlet.rb (Similar template language)](https://github.com/gregwebs/hamlet.rb)
* [Plim (Python port of Slim)](https://github.com/2nd/plim)
* [Skim (Slim for Javascript)](https://github.com/jfirebaugh/skim)
* [Haml (Older engine which inspired Slim)](https://github.com/nex3/haml)
* [Jade (Similar engine for javascript)](https://github.com/visionmedia/jade)