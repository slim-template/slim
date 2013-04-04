# Slim

[![Gem Version](https://badge.fury.io/rb/slim.png)](http://rubygems.org/gems/slim) [![Build Status](https://secure.travis-ci.org/slim-template/slim.png?branch=master)](http://travis-ci.org/slim-template/slim) [![Dependency Status](https://gemnasium.com/slim-template/slim.png?travis)](https://gemnasium.com/slim-template/slim) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/slim-template/slim)

Slim is a template language whose goal is to reduce the view syntax to the essential parts without becoming cryptic. It started as an exercise to see how much could be removed from a standard html template (<, >, closing tags, etc...). As more people took an interest in Slim, the functionality grew and so did the flexibility of the syntax.

A short list of the features...

* Elegant syntax
    * Short syntax without closing tags (Using indentation instead)
    * HTML style mode with closing tags
    * Configurable shortcut tags (`#` for `<div id="...">` and `.` for `<div class="...">` in the default configuration)
* Safety
    * Automatic HTML escaping by default
    * Support for Rails' `html_safe?`
* Highly configurable and extendable via plugins
    * Logic less mode similar to Mustache, realized as plugin
    * Translator/I18n, realized as plugin
* High performance
    * Comparable speed to ERB/Erubis
    * Streaming support in Rails
* Supported by all major frameworks (Rails, Sinatra, ...)
* Embedded engines like Markdown and Textile

## Upgrade to version 2.0

__NOTE:__ Slim 2.0 is not yet released, but you can try the preview versions.

If you are already using Slim 1.3 or 1.2 and want to upgrade to the newest version 2.0, you should at first
upgrade to Slim 1.3.7 which will emit warnings for deprecated features. This way you can easily
see if your application is already Slim 2.0 compliant!

Slim 2.0 removes deprecated features from the 1.3 series and cleans up some minor
inconsistencies in the syntax (Attribute wrapper and quoted attribute escaping).
Of course it also includes new features and bugfixes. See the CHANGES for details.

In general don't be afraid of upgrading! We try to be backward compatible and follow [semantic versions](http://semver.org/)
as good as possible.

## Introduction

### What is Slim?

Slim is a fast, lightweight templating engine with support for __Rails 3 and 4__. It has been heavily tested on all major ruby implementations. We use
continous integration (travis-ci).

Slim's core syntax is guided by one thought: "What's the minimum required to make this work".

As more people have contributed to Slim, there have been syntax additions influenced from their use of [Haml](https://github.com/haml/haml) and [Jade](https://github.com/visionmedia/jade).  The Slim team is open to these additions because we know beauty is in the eye of the beholder.

Slim uses [Temple](https://github.com/judofyr/temple) for parsing/compilation and is also integrated into [Tilt](https://github.com/rtomayko/tilt), so it can be used together with [Sinatra](https://github.com/sinatra/sinatra) or plain [Rack](https://github.com/rack/rack).

The architecture of Temple is very flexible and allows the extension of the parsing and compilation process without monkey-patching. This is used
by the logic less plugin and the translator plugin which provides I18n.

### Why use Slim?

Within the Rails community, _Erb_ and _Haml_ are without doubt the two most popular templating engines. However, _Erb_'s syntax is cumbersome and _Haml_'s syntax can be quite cryptic to the uninitiated.

There is also some development in logic-less engines (e.g. [Mustache](https://github.com/defunkt/mustache) which requires you to write standard HTML). You can also use Slim in logic-less mode if you like the Slim syntax to build your HTML but don't want to write Ruby in your templates.

Slim was born to bring a minimalist syntax approach with speed. If people chose not to use Slim, it would not be because of speed.

___Yes, Slim is speedy!___ Benchmarks are done for every commit at {http://travis-ci.org/#!/slim-template/slim}.
Don't trust the numbers? That's as it should be. Please try the benchmark rake task yourself!

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
          p No items found Please add some inventory.
            Thank you!

        div id="footer"
          = render 'footer'
          | Copyright &copy; #{@year} #{@author}

Indentation matters, but the indentation depth can be chosen as you like. If you want to first indent 2 spaces, then 5 spaces, it's your choice. To nest markup you only need to indent by one space, the rest is gravy.

## Line indicators

### Text `|`

The pipe tells Slim to just copy the line. It essentially escapes any processing.
Each following line that is indented greater than the pipe is copied over.

    body
      p
        |
          This is a test of the text block.

  The parsed result of the above:

    <body><p>This is a test of the text block.</p></body>

  The left margin is set at the indent of the pipe + one space.
  Any additional spaces will be copied over.

    body
      p
        |  This line is on the left margin.
            This line will have one space in front of it.
              This line will have two spaces in front of it.
                And so on...

You can also embed html in the text line

    - articles.each do |a|
      | <tr><td>#{a.name}</td><td>#{a.description}</td></tr>

### Text with trailing white space `'`

The single quote tells Slim to copy the line (similar to `|`), but makes sure that a single trailing white space is appended.

### Inline html `<` (HTML style)

You can write html tags directly in Slim which allows you to write your templates in a more html like style with closing tags or mix html and Slim style.

    <html>
      head
        title Example
      <body>
        - if articles.empty?
        - else
          table
            - articles.each do |a|
              <tr><td>#{a.name}</td><td>#{a.description}</td></tr>
      </body>
    </html>

### Control code `-`

The dash denotes control code.  Examples of control code are loops and conditionals. `end` is forbidden behind `-`. Blocks are defined only by indentation.
If your ruby code needs to use multiple lines, append a backslash `\` at the end of the lines. If your line ends with comma `,` (e.g because of a method call) you don't need the additional backslash before the linebreak.

    body
      - if articles.empty?
        | No inventory

### Output `=`

The equal sign tells Slim it's a Ruby call that produces output to add to the buffer. If your ruby code needs to use multiple lines, append a backslash `\` at the end of the lines, for example:

    = javascript_include_tag \
       "jquery", \
       "application"

If your line ends with comma `,` (e.g because of a method call) you don't need the additional backslash before the linebreak.

### Output with trailing white space `='`

Same as the single equal sign (`=`), except that it adds a trailing white space.

### Output without HTML escaping `==`

Same as the single equal sign (`=`), but does not go through the `escape_html` method.

### Output without HTML escaping and trailing ws `=='`

Same as the double equal sign (`==`), except that it adds a trailing white space.

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

Use the forward slash immediately followed by an exclamation mark for html comments (`<!-- ... -->`).

### IE conditional comment `/[...]`

    /[if IE]
        p Get a better browser.

renders as

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

The attribute value will be escaped if the option `:escape_quoted_attrs` is set. Use == if you want to disable escaping in the attribute.

    a href=="&amp;"

You can break quoted attributes with backslash `\`

    a data-title="help" data-content="extremely long help text that goes on\
      and one and one and then starts over...."

#### Ruby attributes

Write the ruby code directly after the `=`. If the code contains spaces you have to wrap
the code into parentheses `(...)`, `{...}` or `[...]`. The code in the parentheses will be evaluated.

    body
      table
        - for user in users do
          td id="user_#{user.id}" class=user.role
            a href=user_action(user, :edit) Edit #{user.name}
            a href={path_to_user user} = user.name

The attribute value will be escaped by default. Use == if you want to disable escaping in the attribute.

    a href==action_path(:start)

You can also break ruby attributes with backslash `\` or trailing `,` as describe for control sections.

#### Boolean attributes

The attribute values `true`, `false` and `nil` are interpreted
as booleans. If you use the attribut wrapper you can omit the attribute assigment

    input type="text" disabled="disabled"
    input type="text" disabled=true
    input(type="text" disabled)

    input type="text"
    input type="text" disabled=false
    input type="text" disabled=nil

#### Attribute merging

You can configure attributes to be merged if multiple are given (See option `:merge_attrs`). In the default configuration
this is done for class attributes with the white space as delimiter.

    a.menu class="highlight" href="http://slim-lang.com/" Slim-lang.com

This renders as

    <a class="menu highlight" href="http://slim-lang.com/">Slim-lang.com</a>

You can also use an `Array` as attribute value and the array elements will be merged using the delimiter.

    a class=["menu","highlight"]
    a class=:menu,:highlight

#### Splat attributes `*`

The splat shortcut allows you turn a hash in to attribute/value pairs

    .card*{'data-url'=>place_path(place), 'data-id'=>place.id} = place.name

renders as

    <div class="card" data-id="1234" data-url="/place/1234">Slim's house</div>

You can also use methods or instance variables which return a hash as shown here:

    .card *method_which_returns_hash = place.name
    .card *@hash_instance_variable = place.name

The hash attributes which support attribute merging (see Slim option `:merge_attrs`) can be given as an `Array`

    .first *{:class => [:second, :third]} Text

renders as

    div class="first second third"

#### Dynamic tags `*`

You can create completely dynamic tags using the splat attributes. Just create a method which returns a hash
with the :tag key.

    ruby:
      def a_unless_current
        @page_current ? {:tag => 'span'} : {:tag => 'a', :href => 'http://slim-lang.com/'}
      end
    - @page_current = true
    *a_unless_current Link
    - @page_current = false
    *a_unless_current Link

renders as

    <span>Link</span><a href="http://slim-lang.com/">Link</a>

### Shortcuts

#### Tag shortcuts

You can define custom tag shortcuts by setting the option `:shortcut`.

    Slim::Engine.set_default_options :shortcut => {'c' => {:tag => 'container'}, '#' => {:attr => 'id'}, '.' => {:attr => 'class'} }

We can use it in Slim code like this

    c.content Text

which renders to

    <container class="content">Text</container>

#### Attribute shortcuts

You can define custom shortcuts (Similar to `#` for id and `.` for class).

In this example we add `&` to create a shortcut for the input elements with type attribute.

    Slim::Engine.set_default_options :shortcut => {'&' => {:tag => 'input', :attr => 'type'}, '#' => {:attr => 'id'}, '.' => {:attr => 'class'}}

We can use it in Slim code like this

    &text name="user"
    &password name="pw"
    &submit

which renders to

    <input type="text" name="user" />
    <input type="password" name="pw" />
    <input type="submit" />

In another example we add `@` to create a shortcut for the role attribute.

    Slim::Engine.set_default_options :shortcut => {'@' => {:attr => 'role'}, '#' => {:attr => 'id'}, '.' => {:attr => 'class'}}

We can use it in Slim code like this

    .person@admin = person.name

which renders to

    <div class="person" role="admin">Daniel</div>

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

## Text interpolation

Use standard Ruby interpolation. The text will be html escaped by default.

    body
      h1 Welcome #{current_user.name} to the show.
      | Unescaped #{{content}} is also possible.

To escape the interpolation (i.e. render as is)

    body
      h1 Welcome \#{current_user.name} to the show.

## Embedded engines (Markdown, ...)

Thanks to [Tilt](https://github.com/rtomayko/tilt), Slim has impressive support for embedding other template engines.

Examples:

    coffee:
      square = (x) -> x * x

    markdown:
      #Header
        Hello from #{"Markdown!"}
        Second Line!

Supported engines:

<table>
<thead style="font-weight:bold"><tr><td>Filter</td><td>Required gems</td><td>Type</td><td>Description</td></tr></thead>
<tbody>
<tr><td>ruby:</td><td>none</td><td>Shortcut</td><td>Shortcut to embed ruby code</td></tr>
<tr><td>javascript:</td><td>none</td><td>Shortcut</td><td>Shortcut to embed javascript code and wrap in script tag</td></tr>
<tr><td>css:</td><td>none</td><td>Shortcut</td><td>Shortcut to embed css code and wrap in style tag</td></tr>
<tr><td>sass:</td><td>sass</td><td>Compile time</td><td>Embed sass code and wrap in style tag</td></tr>
<tr><td>scss:</td><td>sass</td><td>Compile time</td><td>Embedd scss code and wrap in style tag</td></tr>
<tr><td>less:</td><td>less</td><td>Compile time</td><td>Embed less css code and wrap in style tag</td></tr>
<tr><td>styl:</td><td>styl</td><td>Compile time</td><td>Embed stylus css code and wrap in style tag</td></tr>
<tr><td>coffee:</td><td>coffee-script</td><td>Compile time</td><td>Compile coffee script code and wrap in script tag</td></tr>
<tr><td>asciidoc:</td><td>asciidoctor</td><td>Compile time + Interpolation</td><td>Compile AsciiDoc code and interpolate #\{variables} in text</td></tr>
<tr><td>markdown:</td><td>redcarpet/rdiscount/kramdown</td><td>Compile time + Interpolation</td><td>Compile markdown code and interpolate #\{variables} in text</td></tr>
<tr><td>textile:</td><td>redcloth</td><td>Compile time + Interpolation</td><td>Compile textile code and interpolate #\{variables} in text</td></tr>
<tr><td>creole:</td><td>creole</td><td>Compile time + Interpolation</td><td>Compile creole code and interpolate #\{variables} in text</td></tr>
<tr><td>wiki:, mediawiki:</td><td>wikicloth</td><td>Compile time + Interpolation</td><td>Compile wiki code and interpolate #\{variables} in text</td></tr>
<tr><td>rdoc:</td><td>rdoc</td><td>Compile time + Interpolation</td><td>Compile rdoc code and interpolate #\{variables} in text</td></tr>
<tr><td>builder:</td><td>builder</td><td>Precompiled</td><td>Embed builder code</td></tr>
<tr><td>nokogiri:</td><td>nokogiri</td><td>Precompiled</td><td>Embed nokogiri builder code</td></tr>
<tr><td>erb:</td><td>none</td><td>Precompiled</td><td>Embed erb code</td></tr>
</tbody>
</table>

The embedded engines can be configured in Slim by setting the options directly on the `Slim::Embedded` filter. Example:

    Slim::Embedded.default_options[:markdown] = {:auto_ids => false}

## Configuring Slim

Slim and the underlying [Temple](https://github.com/judofyr/temple) framework are highly configurable.
The way how you configure Slim depends a bit on the compilation mechanism (Rails or [Tilt](https://github.com/rtomayko/tilt)). It is always possible to set default options per `Slim::Engine` class. This can be done in Rails' environment files. For instance, in config/environments/development.rb you probably want:

### Default options

    # Indent html for pretty debugging and do not sort attributes (Ruby 1.8)
    Slim::Engine.set_default_options :pretty => true, :sort_attrs => false

    # Indent html for pretty debugging and do not sort attributes (Ruby 1.9)
    Slim::Engine.set_default_options pretty: true, sort_attrs: false

You can also access the option hash directly:

    Slim::Engine.default_options[:pretty] = true

### Setting options at runtime

There are two ways to set options at runtime. For Tilt templates (`Slim::Template`) you can set
the options when you instatiate the template:

    Slim::Template.new('template.slim', optional_option_hash).render(scope)

The other possibility is to set the options per thread which is interesting mostly for Rails:

    Slim::Engine.with_options(option_hash) do
       # Any Slim engines which are created here use the option_hash
       # For example in Rails:
       render :page, :layout => true
    end

You have to be aware that the compiled engine code and the options are cached per template in Rails and you cannot change the option afterwards.

    # First render call
    Slim::Engine.with_options(:pretty => true) do
       render :page, :layout => true
    end

    # Second render call
    Slim::Engine.with_options(:pretty => false) do
       render :page, :layout => true # :pretty is still true because it is cached
    end

### Available options

The following options are exposed by the `Slim::Engine` and can be set with `Slim::Engine.set_default_options`.
There are a lot of them but the good thing is, that Slim checks the configuration keys and reports an error if you try to use an invalid configuration key.

<table>
<thead style="font-weight:bold"><tr><td>Type</td><td>Name</td><td>Default</td><td>Purpose</td></tr></thead>
<tbody>
<tr><td>String</td><td>:file</td><td>nil</td><td>Name of parsed file, set automatically by Slim::Template</td></tr>
<tr><td>Integer</td><td>:tabsize</td><td>4</td><td>Number of white spaces per tab (used by the parser)</td></tr>
<tr><td>String</td><td>:encoding</td><td>"utf-8"</td><td>Set encoding of template</td></tr>
<tr><td>String</td><td>:default_tag</td><td>"div"</td><td>Default tag to be used if tag name is omitted</td></tr>
<tr><td>Hash</td><td>:shortcut</td><td>\{'.' => {:attr => 'class'}, '#' => {:attr => 'id'}}</td><td>Attribute shortcuts</td></tr>
<tr><td>Array&lt;Symbol,String&gt;</td><td>:enable_engines</td><td>nil <i>(All enabled)</i></td><td>List of enabled embedded engines (whitelist)</td></tr>
<tr><td>Array&lt;Symbol,String&gt;</td><td>:disable_engines</td><td>nil <i>(None disabled)</i></td><td>List of disabled embedded engines (blacklist)</td></tr>
<tr><td>Boolean</td><td>:disable_capture</td><td>false (true in Rails)</td><td>Disable capturing in blocks (blocks write to the default buffer </td></tr>
<tr><td>Boolean</td><td>:disable_escape</td><td>false</td><td>Disable automatic escaping of strings</td></tr>
<tr><td>Boolean</td><td>:escape_quoted_attrs</td><td>false</td><td>Escape quoted attributes. <b>Option is removed and activated per default in Slim 2.0!</b></td></tr>
<tr><td>Boolean</td><td>:use_html_safe</td><td>false (true in Rails)</td><td>Use String#html_safe? from ActiveSupport (Works together with :disable_escape)</td></tr>
<tr><td>Symbol</td><td>:format</td><td>:xhtml</td><td>HTML output format (Possible formats :xhtml, :html4, :html5, :html)</td></tr>
<tr><td>String</td><td>:attr_quote</td><td>'"'</td><td>Character to wrap attributes in html (can be ' or ")</td></tr>
<tr><td>Hash</td><td>:merge_attrs</td><td>\{'class' => ' '}</td><td>Joining character used if multiple html attributes are supplied (e.g. class="class1 class2")</td></tr>
<tr><td>Boolean</td><td>:sort_attrs</td><td>true</td><td>Sort attributes by name</td></tr>
<tr><td>Symbol</td><td>:js_wrapper</td><td>nil</td><td>Wrap javascript by :comment, :cdata or :both. You can also :guess the wrapper based on :format.</td></tr>
<tr><td>Boolean</td><td>:pretty</td><td>false</td><td>Pretty html indenting <b>(This is slower!)</b></td></tr>
<tr><td>String</td><td>:indent</td><td>'  '</td><td>Indentation string</td></tr>
<tr><td>Boolean</td><td>:streaming</td><td>false (true in Rails > 3.1)</td><td>Enable output streaming</td></tr>
<tr><td>Class</td><td>:generator</td><td>Temple::Generators::ArrayBuffer/RailsOutputBuffer</td><td>Temple code generator (default generator generates array buffer)</td></tr>
<tr><td>String</td><td>:buffer</td><td>'_buf' ('@output_buffer' in Rails)</td><td>Variable used for buffer</td></tr>
</tbody>
</table>

There are more options which are supported by the Temple filters but which are not exposed and are not officially supported. You
have to take a look at the Slim and Temple code for that.

### Option priority and inheritance

For developers who know more about Slim and Temple architecture it is possible to override default
options at different positions. Temple uses an inheritance mechanism to allow subclasses to override
options of the superclass. The option priorities are as follows:

1. `Slim::Template` options passed at engine instatination
2. `Slim::Template.default_options`
3. `Slim::Engine.thread_options`, `Slim::Engine.default_options`
5. Parser/Filter/Generator `thread_options`, `default_options` (e.g `Slim::Parser`, `Slim::Compiler`)

It is also possible to set options for superclasses like `Temple::Engine`. But this will affect all temple template engines then.

    Slim::Engine < Temple::Engine
    Slim::Compiler < Temple::Filter

## Plugins

### Logic less mode

<a name="logicless">Logic less mode</a> is inspired by [Mustache](https://github.com/defunkt/mustache). Logic less mode uses a dictionary object
e.g. a recursive hash tree which contains the dynamic content.

#### Conditional

If the object is not false or empty?, the content will show

    - article
      h1 = title

#### Inverted conditional

If the object is false or empty?, the content will show

    -! article
      p Sorry, article not found

#### Iteration

If the object is an array, the section will iterate

    - articles
      tr: td = title

#### Lambdas

Like mustache, Slim supports lambdas.

    = person
      = name

The lambda method could be defined like this

    def lambda_method
      "<div class='person'>#{yield(:name => 'Andrew')}</div>"
    end

You can optionally pass one or more hashes to `yield`. If you pass multiple hashes, the block will be iterated as described above.

#### Dictionary access

Example code:

    - article
      h1 = title

The dictionary object is accessed in the order given by the `:dictionary_access`. Default order:

1. `:symbol` - If `article.respond_to?(:has_key?)` and `article.has_key?(:title)`, Slim will execute `article[:title]`
2. `:string` - If `article.respond_to?(:has_key?)` and `article.has_key?('title')`, Slim will execute `article['title']`
3. `:method` - If `article.respond_to?(:title)`, Slim will execute `article.send(:title)`
4. `:instance_variable` - If `article.instance_variable_defined?(@title)`, Slim will execute `article.instance_variable_get @title`

If all the above fails, Slim will try to resolve the title reference in the same order against the parent object. In this example, the parent would be the dictionary object you are rendering the template against.

As you might have guessed, the article reference goes through the same steps against the dictionary. Instance variables are not allowed in the view code, but Slim will find and use them. Essentially, you're just using dropping the @ prefix in your template. Parameterized method calls are not allowed.

#### Logic less in Rails

Install:

    $ gem install slim

Require:

    gem 'slim', :require => 'slim/logic_less'

You might want to activate logic less mode only for a few actions, you should disable logic-less mode globally at first in the configuration

    Slim::Engine.set_default_options :logic_less => false

and activate logic less mode per render call in your action

    class Controller
      def action
        Slim::Engine.with_options(:logic_less => true) do
          render
        end
      end
    end

#### Logic less in Sinatra

Sinata has built-in support for Slim. All you have to do is require the logic less Slim plugin. This can be done in your config.ru:

    require 'slim/logic_less'

You are then ready to rock!

You might want to activate logic less mode only for a few actions, you should disable logic-less mode globally at first in the configuration

    Slim::Engine.set_default_options :logic_less => false

and activate logic less mode per render call in your application

    get '/page'
      slim :page, :logic_less => true
    end

#### Options

<table>
<thead style="font-weight:bold"><tr><td>Type</td><td>Name</td><td>Default</td><td>Purpose</td></tr></thead>
<tbody>
<tr><td>Boolean</td><td>:logic_less</td><td>true</td><td>Enable logic less mode (Enabled if 'slim/logic_less' is required)</td></tr>
<tr><td>String</td><td>:dictionary</td><td>"self"</td><td>Dictionary where variables are looked up</td></tr>
<tr><td>Symbol/Array&lt;Symbol&gt;</td><td>:dictionary_access</td><td>[:symbol, :string, :method, :instance_variable]</td><td>Dictionary access order (:symbol, :string, :method, :instance_variable)</td></tr>
</tbody>
</table>

### Translator/I18n

The translator plugin provides automatic translation of the templates using Gettext, Fast-Gettext or Rails I18n. Static text
in the template is replaced by the translated version.

Example:

    h1 Welcome to #{url}!

Gettext translates the string from english to german where interpolations are replaced by %1, %2, ...

    "Welcome to %1!" -> "Willkommen auf %1!"

and renders as

    <h1>Willkommen auf slim-lang.com!</h1>

Enable the translator plugin with

    require 'slim/translator'

#### Options

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

Slim uses [Tilt](https://github.com/rtomayko/tilt) to compile the generated code. If you want to use the Slim template directly, you can use the Tilt interface.

    Tilt.new['template.slim'].render(scope)
    Slim::Template.new('template.slim', optional_option_hash).render(scope)
    Slim::Template.new(optional_option_hash) { source }.render(scope)

The optional option hash can have to options which were documented in the section above.

### Sinatra

<pre>require 'sinatra'
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

Rails generators are provided by [slim-rails](https://github.com/slim-template/slim-rails). slim-rails
is not necessary to use Slim in Rails though. Just install Slim and add it to your Gemfile with `gem 'slim'`.
Then just use the .slim extension and you're good to go.

#### Streaming

HTTP streaming is enabled by default if you use a Rails version which supports it.

## Tools

### Slim Command 'slimrb'

The gem 'slim' comes with the small tool 'slimrb' to test Slim from the command line.

<pre>
$ slimrb --help
Usage: slimrb [options]
    -s, --stdin                      Read input from standard input instead of an input file
        --trace                      Show a full traceback on error
    -c, --compile                    Compile only but do not run
    -r, --rails                      Generate rails compatible code (Implies --compile)
    -t, --translator                 Enable translator plugin
    -l, --logic-less                 Enable logic less plugin
    -p, --pretty                     Produce pretty html
    -o, --option [NAME=CODE]         Set slim option
    -h, --help                       Show this message
    -v, --version                    Print version
</pre>

Start 'slimrb', type your code and press Ctrl-d to send EOF. Example usage:

<pre>
$ slimrb
markdown:
  First paragraph.

  Second paragraph.

  * one
  * two
  * three

//Enter Ctrl-d
&lt;p&gt;First paragraph &lt;/p&gt;

&lt;p&gt;Second paragraph &lt;/p&gt;

&lt;ul&gt;
&lt;li&gt;one&lt;/li&gt;
&lt;li&gt;two&lt;/li&gt;
&lt;li&gt;three&lt;/li&gt;
&lt;/ul&gt;
</pre>

### Syntax Highlighters

There are plugins for various text editors (including the most important ones - Vim, Emacs and Textmate):

* [Vim](https://github.com/slim-template/vim-slim)
* [Emacs](https://github.com/slim-template/emacs-slim)
* [Textmate / Sublime Text](https://github.com/slim-template/ruby-slim.tmbundle)
* [Espresso text editor](https://github.com/slim-template/Slim-Sugar)
* [Coda](https://github.com/slim-template/Coda-2-Slim.mode)

### Template Converters (HAML, ERB, ...)

* [Haml2Slim converter](https://github.com/slim-template/haml2slim)
* [HTML2Slim converter](https://github.com/slim-template/html2slim)

## Testing

### Benchmarks

  *Yes, Slim is one of the fastest Ruby template engines out there!
   In production mode Slim is nearly as fast as Erubis (which is the fastest template engine).
   But we would be happy if you chose Slim also for any other reason, we assure
   you performance will not be an obstacle.*

Run the benchmarks with `rake bench`. You can add the option `slow` to
run the slow parsing benchmark which needs more time. You can also increase the number of iterations.

    rake bench slow=1 iterations=1000

We run the benchmarks for every commit on Travis-CI. Take a look at the newest benchmarking results: {http://travis-ci.org/#!/slim-template/slim}

### Test suite and continous integration

Slim provides an extensive test-suite based on minitest. You can run the tests
with 'rake test' and the rails integration tests with 'rake test:rails'.

We are currently experimenting with human-readable literate tests which are written as markdown files: {file:test/literate/TESTS.md TESTS.md}

Travis-CI is used for continous integration testing: {http://travis-ci.org/#!/slim-template/slim}

Slim is working well on all major Ruby implementations:

* Ruby 1.8.7
* Ruby 1.9.2
* Ruby 1.9.3
* Ruby EE
* JRuby
* Rubinius 2.0

## Contributing

If you'd like to help improve Slim, clone the project with Git by running:

    $ git clone git://github.com/slim-template/slim

Work your magic and then submit a pull request. We love pull requests!

Please remember to test against Ruby versions 1.9.2 and 1.8.7.

If you find the documentation lacking (and you probably will), help us out and update this README.md. If you don't have the time to work on Slim, but found something we should know about, please submit an issue.

## License

Slim is released under the [MIT license](http://www.opensource.org/licenses/MIT).

## Authors

* [Daniel Mendler](https://github.com/minad) (Lead developer)
* [Andrew Stone](https://github.com/stonean)
* [Fred Wu](https://github.com/fredwu)

## Discuss

* [Google Group](http://groups.google.com/group/slim-template)

## Related projects

Template compilation framework:

* [Temple](https://github.com/judofyr/temple)

Framework support:

* [Rails generators (slim-rails)](https://github.com/slim-template/slim-rails)

Syntax highlighting:

* [Vim](https://github.com/slim-template/vim-slim)
* [Emacs](https://github.com/slim-template/emacs-slim)
* [Textmate / Sublime Text](https://github.com/slim-template/ruby-slim.tmbundle)
* [Espresso text editor](https://github.com/slim-template/Slim-Sugar)
* [Coda](https://github.com/slim-template/Coda-2-Slim.mode)

Template Converters (HAML, ERB, ...):

* [Haml2Slim converter](https://github.com/slim-template/haml2slim)
* [HTML2Slim converter](https://github.com/slim-template/html2slim)

Language ports/Similar languages:

* [Coffee script plugin for Slim](https://github.com/yury/coffee-views)
* [Clojure port of Slim](https://github.com/chaslemley/slim.clj)
* [Hamlet.rb (Similar template language)](https://github.com/gregwebs/hamlet.rb)
* [Plim (Python port of Slim)](https://github.com/2nd/plim)
* [Skim (Slim for Javascript)](https://github.com/jfirebaugh/skim)
* [Haml (Older engine which inspired Slim)](https://github.com/haml/haml)
* [Jade (Similar engine for javascript)](https://github.com/visionmedia/jade)
