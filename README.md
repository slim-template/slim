# Slim


[![Build Status](https://secure.travis-ci.org/stonean/slim.png?branch=master)](http://travis-ci.org/stonean/slim) [![Dependency Status](https://gemnasium.com/stonean/slim.png?travis)](https://gemnasium.com/stonean/slim) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/stonean/slim)

Slim is a template language whose goal is to reduce the view syntax to the essential parts without becoming cryptic.


## What?

Slim is a fast, lightweight templating engine with support for __Rails 3__. It has been tested on Ruby 1.9.2 and Ruby/REE 1.8.7.

Slim's core syntax is guided by one thought: "What's the minimum required to make this work".

As more people have contributed to Slim, there have been ___optional___ syntax additions influenced from their use of [Haml](https://github.com/nex3/haml) and [Jade](https://github.com/visionmedia/jade).  The Slim team is open to these optional additions because we know beauty is in the eye of the beholder.

Slim uses [Temple](https://github.com/judofyr/temple) for parsing/compilation and is also integrated into [Tilt](https://github.com/rtomayko/tilt), so it can be used together with [Sinatra](https://github.com/sinatra/sinatra) or plain [Rack](https://github.com/rack/rack).

## Why?

Within the Rails community, _Erb_ and _Haml_ are without doubt the two most popular templating engines. However, _Erb_'s syntax is cumbersome and _Haml_'s syntax can be quite cryptic to the uninitiated.

Slim was born to bring a minimalist syntax approach with speed. If people chose not to use Slim, it would not be because of speed.

___Yes, Slim is speedy!___ Benchmarks are provided at the end of this README file. Don't trust the numbers? That's as it should be. Therefore we provide a benchmark rake task so you could test it yourself (`rake bench`).

## How?

Install Slim as a gem:

    gem install slim

Include Slim in your Gemfile:

    gem 'slim'

That's it! Now, just use the .slim extension and you're good to go.

If you want to use the Slim template directly, you can use the Tilt interface:

    Tilt.new['template.slim'].render(scope)
    Slim::Template.new(filename, optional_option_hash).render(scope)
    Slim::Template.new(optional_option_hash) { source }.render(scope)

## Syntax Highlighters

There are plugins for Vim, Emacs, Textmate and Espresso text editor:

* [Vim](https://github.com/bbommarito/vim-slim)
* [Textmate](https://github.com/fredwu/ruby-slim-tmbundle)
* [Emacs](https://github.com/minad/emacs-slim)
* [Espresso text editor](https://github.com/CiiDub/Slim-Sugar)

## Template Converters

For Haml, there is a [Haml2Slim converter](https://github.com/fredwu/haml2slim). For HTML, there is a [HTML2Slim converter](https://github.com/joaomilho/html2slim).

## The syntax

As a Rails developer, you might already be very familiar with _Haml_'s syntax and you think it is fantastic - until you entered the magic kingdom of _node.js_ and got introduced to _Jade_.

Slim's syntax has been influenced by both _Haml_ and _Jade_.

Here's a quick example to demonstrate what a Slim template looks like:

    doctype html
    html
      head
        title Slim Examples
        meta name="keywords" content="template language"

      body
        h1 Markup examples
        #content.example1
          p Nest by indentation

        = yield

        - if items.any?
          table
            - for item in items do
              tr
                td = item.name
                td = item.price
        - else
          p No items found

        #footer
          | Copyright &copy; 2010 Andrew Stone

        = render 'tracking_code'

        script
          | $(content).do_something();


## Language features

### Line indicators

#### `|`

> The pipe tells Slim to just copy the line. It essentially escapes any processing.

#### `'`

> The single quote tells Slim to copy the line (similar to |), but makes sure that a single trailing space is appended.

#### `-`

> The dash denotes control code (similar to Haml).  Examples of control code are loops and conditionals.

#### `=`

> The equal sign tells Slim it's a Ruby call that produces output to add to the buffer (similar to Erb and Haml).

#### `='`

> Same as the single equal sign (`=`), except that it adds a trailing whitespace.

#### `==`

> Same as the single equal sign (`=`), but does not go through the `escape_html` method.

#### `=='`

> Same as the double equal sign (`==`), except that it adds a trailing whitespace.

#### `/`

> Use the forward slash for ruby code comments - anything after it won't get displayed in the final render.

#### `/!`

> Use the forward slash immediately followed by an exclamation mark for html comments (` <!-- --> `).


### Things to know

#### Standard Ruby syntax after `-` and `=`
  `end` is forbidden behind `-`. Blocks are defined only by indentation.

#### Can put content on same line or nest it.
  If you nest content (e.g. put it on the next line), start the line with a pipe (`|`) or a single quote (`` ' ``).

#### Indentation matters, but it's not as strict as Haml.
  If you want to first indent 2 spaces, then 5 spaces, it's your choice. To nest markup you only need to indent by one space, the rest is gravy.

#### If your ruby code needs to use multiple lines, append a `\` at the end of the lines, for example:
    = javascript_include_tag \
       "jquery", \
       "application"

### Wrap attributes with delimiters

  If a delimiter makes the syntax more readable for you,
  you can use the characters {...}, (...), [...] to wrap the attributes.

    body
      h1(id="logo") = page_logo
      h2[id="tagline" class="small tagline"] = page_tagline


  If you wrap the attributes, you can spread them across multiple lines:

    h2[ id="tagline"
        class="small tagline"] = page_tagline

### Add content to a tag

  Either start on the same line as the tag

    body
      h1 id="headline" Welcome to my site.

  Or nest it.  __Note:__ Must use a pipe or a backtick to escape processing

    body
      h1 id="headline"
        | Welcome to my site.

### Add content to a tag with code

  Can make the call on the same line

    body
      h1 id="headline" = page_headline

  Or nest it.

    body
      h1 id="headline"
        = page_headline

### Shortcut form for `id` and `class` attributes

  Similarly to Haml, you can specify the `id` and `class`
  attributes in the following shortcut form
  Note: the shortcut form does not evaluate ruby code

    body
      h1#headline
        = page_headline
      h2#tagline.small.tagline
        = page_tagline
      .content
        = show_content

  this is the same as

    body
      h1 id="headline"
        = page_headline
      h2 id="tagline" class="small tagline"
        = page_tagline
      div class="content"
        = show_content

### Inline tags

  Sometimes you may want to be a little more compact and inline the tags.

    ul
      li.first: a href="/a" A link
      li: a href="/b" B link

  For readability, don't forget you can wrap the attributes.

    ul
      li.first: a[href="/a"] A link
      li: a[href="/b"] B link

### Set an attribute's value with a method

  * Alternative 1: Use parentheses (), {}, []. The code in the parentheses will be evaluated.
  * Alternative 2: If the code doesn't contain any spaces you can omit the parentheses.
  * Alternative 3: Use standard ruby interpolation #{}

  Attributes will always be html escaped.

    body
      table
        - for user in users do
          td id="user_#{user.id}" class=user.role
            a href=user_action(user, :edit) Edit #{user.name}
            a href={path_to_user user} = user.name

### Evaluate ruby code in text

  Use standard Ruby interpolation. The text will be html escaped by default.

    body
      h1 Welcome #{current_user.name} to the show.
      | Unescaped #{{content}} is also possible.

  To escape the interpolation (i.e. render as is)

    body
      h1 Welcome \#{current_user.name} to the show.

### Skip the html escaping

  Use a double equal sign

    body
      h1 id="headline"
        == page_headline

  Alternatively, if you prefer to use single equal sign, you may do so by setting the `disable_escape` option to true.

    Slim::Engine.default_options[:disable_escape] = true

### Treat multiple lines of code as text that should bypass parsing

  Use a pipe (`|`) or single quote (`` ' ``) to start the escape.
  Each following line that is indented greater than
  the backtick is copied over.

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

### Add comments

  Use `/` for ruby code comments and `/!` for html comments

    body
      p
        / This line won't get displayed.
          Neither does this line.
        /! This will get displayed as html comments.

  The parsed result of the above:

    <body><p><!--This will get displayed as html comments.--></p></body>

## Benchmarks

  *The benchmarks are only to demonstrate that Slim's speed should not
  be a determining factor in your template choice. Even if we don't
  agree, we'd prefer you to use any other reason for choosing another
  template language.*

    # Linux + Ruby 1.9.3, 1000 iterations

                          user     system      total        real
    (1) erb           0.050000   0.000000   0.050000 (  0.045452)
    (1) erubis        0.040000   0.000000   0.040000 (  0.036509)
    (1) fast erubis   0.030000   0.000000   0.030000 (  0.036500)
    (1) slim          0.060000   0.000000   0.060000 (  0.053998)
    (1) haml          0.280000   0.000000   0.280000 (  0.275243)
    (1) haml ugly     0.250000   0.000000   0.250000 (  0.251369)
    (2) erb           0.100000   0.000000   0.100000 (  0.093496)
    (2) erubis        0.060000   0.000000   0.060000 (  0.055383)
    (2) slim          0.070000   0.000000   0.070000 (  0.071306)
    (2) haml          0.320000   0.000000   0.320000 (  0.332470)
    (2) haml ugly     0.300000   0.000000   0.300000 (  0.298213)
    (3) erb           0.350000   0.010000   0.360000 (  0.353701)
    (3) erubis        0.280000   0.000000   0.280000 (  0.282352)
    (3) fast erubis   0.250000   0.000000   0.250000 (  0.241812)
    (3) slim          0.070000   0.000000   0.070000 (  0.071439)
    (3) haml          0.740000   0.000000   0.740000 (  0.743727)
    (3) haml ugly     0.590000   0.000000   0.590000 (  0.590633)
    (4) erb           0.850000   0.010000   0.860000 (  0.857154)
    (4) erubis        0.740000   0.000000   0.740000 (  0.738498)
    (4) fast erubis   0.730000   0.000000   0.730000 (  0.739184)
    (4) slim          7.300000   0.030000   7.330000 (  7.340021)
    (4) haml          5.420000   0.050000   5.470000 (  5.495866)
    (4) haml ugly     5.020000   0.020000   5.040000 (  5.039538)

    1. Compiled benchmark. Template is parsed before the benchmark and
       generated ruby code is compiled into a method.
       This is the fastest evaluation strategy because it benchmarks
       pure execution speed of the generated ruby code.

    2. Compiled Tilt benchmark. Template is compiled with Tilt, which gives a more
       accurate result of the performance in production mode in frameworks like
       Sinatra, Ramaze and Camping. (Rails still uses its own template
       compilation.)

    3. Cached benchmark. Template is parsed before the benchmark.
       The ruby code generated by the template engine might be evaluated every time.
       This benchmark uses the standard API of the template engine.

    4. Uncached benchmark. Template is parsed every time.
       This is not the recommended way to use the template engine
       and Slim is not optimized for it. Activate this benchmark with 'rake bench slow=1'.

## Tests

Slim provides an extensive test-suite based on minitest. You can run the tests
with 'rake test' and the rails integration tests with 'rake test:rails'.

Travis-CI is used for continous integration testing: http://travis-ci.org/#!/stonean/slim

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

## Slim related projects

* [Temple](https://github.com/judofyr/slim)

* [Vim syntax highlighting](https://github.com/bbommarito/vim-slim)
* [Emacs syntax highlighting](https://github.com/minad/emacs-slim)
* [Textmate bundle](https://github.com/fredwu/ruby-slim-tmbundle)
* [Slim support for the Espresso text editor from MacRabbits](https://github.com/CiiDub/Slim-Sugar)

* [Haml2Slim converter](https://github.com/fredwu/haml2slim)
* [Html2Slim converter](https://github.com/joaomilho/html2slim)

* [Rails 3 Generators](https://github.com/leogalmeida/slim-rails)

* [Coffee script plugin for Slim](https://github.com/yury/coffee-views)

* [Clojure port of Slim](https://github.com/chaslemley/slim.clj)
* [Hamlet.rb (Similar template language)](https://github.com/gregwebs/hamlet.rb)
* [Plim (Python port of Slim)](https://github.com/2nd/plim)
* [Skim (Slim for Javascript)](https://github.com/jfirebaugh/skim)

