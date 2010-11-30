# Slim

Slim is a template language whose goal is to reduce the view syntax to the essential parts without becoming cryptic.


## What?

Slim is a fast, lightweight templating engine with support for __Rails 3__. It has been tested on Ruby 1.9.2 and Ruby/REE 1.8.7.

Slim's core syntax is guided by one thought: "What's the minimum required to make this work".

As more people have contributed to Slim, there have been ___optional___ syntax additions influenced from their use of [Haml](http://github.com/nex3/haml) and [Jade](http://github.com/visionmedia/jade).  The Slim team is open to these optional additions because we know beauty is in the eye of the beholder.

Slim uses [Temple](http://github.com/judofyr/temple) for parsing/compilation and is also integrated into [Tilt](http://github.com/rtomayko/tilt), so it can be used together with [Sinatra](http://github.com/sinatra/sinatra) or plain [Rack](http://github.com/rack/rack).

## Why?

Within the Rails community, _Erb_ and _Haml_ are without doubt the two most popular templating engines. However, _Erb_'s syntax is cumbersome and _Haml_'s performance isn't exactly the best.

Slim was born to bring a minimalist syntax approach with speed. If people chose not to use Slim, it would not be because of speed.

___Yes, Slim is speedy!___ Benchmarks are provided at the end of this README file. Alternatively, a benchmark rake task is provided so you could test it yourself (`rake bench`).

## How?

Install Slim as a gem:

    gem install slim

Include Slim in your Gemfile:

    gem 'slim', :require => 'slim/rails'

That's it! Now, just use the .slim extension and you're good to go.

If you want to use the Slim template directly, you can use the Tilt interface:

    Tilt.new['template.slim'].render(scope)
    Slim::Template.new(filename, optional_option_hash).render(scope)
    Slim::Template.new(optional_option_hash) { source }.render(scope)

## Syntax Highlighters

Syntax highlight support for __Vim__ (very beta) and __Emacs__ are included in the `extra` folder. There is also a [Textmate bundle](http://github.com/fredwu/ruby-slim-textmate-bundle).

## The syntax

As a Rails developer, you might already be very familiar with _Haml_'s syntax and you think it is fantastic - until you entered the magic kingdom of _node.js_ and got introduced to _Jade_.

Slim's syntax has been influenced by both _Haml_ and _Jade_.

Here's a quick example to demonstrate what a Slim template looks like:

    ! doctype html
    html
      head
        title Slim Examples
        meta name="keywords" content="template language"

      body
        h1 Markup examples
        #content.example1
          p Nest by indentation

        = yield

        - unless items.empty?
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

#### `==`

> Same as the single equal sign, but does not go through the escape_html method.

#### `!`

> This is a directive.  Most common example: `! doctype html # renders <!doctype html>`

#### `/`

> Use the forward slash for ruby code comments - anything after it won't get displayed in the final render.

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
       "application"`

### Wrap attributes with delimiters

  If a delimiter makes the syntax more readable for you,
  you can use the characters {...}, (...), [...] to wrap the attributes.

    body
      h1(id="logo") = page_logo
      h2[id="tagline" class="small tagline"] = page_tagline

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

  Use standard Ruby interpolation. The text will always be html escaped.

    body
      h1 Welcome #{current_user.name} to the show.

  To escape the interpolation (i.e. render as is)

    body
      h1 Welcome \#{current_user.name} to the show.

### Skip the html escaping

  Use a double equal sign

    body
      h1 id="headline"
        == page_headline

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

### Add code comments

  Use a forward slash for ruby code comments

    body
      p
        / This line won't get displayed.
          Neither does this line.

  The parsed result of the above:

    <body><p></p></body>

## Benchmarks

    # OS X 10.6 + Ruby 1.9.2

                                 user     system      total        real
    erb                      2.200000   0.020000   2.220000 (  2.259262)
    erubis                   1.870000   0.010000   1.880000 (  1.895547)
    fast erubis              1.870000   0.010000   1.880000 (  1.887996)
    slim                    10.380000   0.080000  10.460000 ( 10.543296)
    haml                    16.250000   0.070000  16.320000 ( 16.376137)
    haml ugly               15.700000   0.080000  15.780000 ( 15.869233)
    erb (compiled)           0.820000   0.010000   0.830000 (  0.821538)
    erubis (compiled)        0.680000   0.000000   0.680000 (  0.680444)
    fast erubis (compiled)   0.600000   0.010000   0.610000 (  0.605370)
    slim (compiled)          0.180000   0.000000   0.180000 (  0.182536)
    haml (compiled)          1.800000   0.020000   1.820000 (  1.863224)
    haml ugly (compiled)     1.560000   0.020000   1.580000 (  1.602106)
    erb (cached)             0.120000   0.000000   0.120000 (  0.127988)
    erubis (cached)          0.110000   0.000000   0.110000 (  0.115064)
    fast erubis (cached)     0.120000   0.010000   0.130000 (  0.122645)
    slim (cached)            0.140000   0.000000   0.140000 (  0.134598)
    haml (cached)            0.660000   0.000000   0.660000 (  0.661025)
    haml ugly (cached)       0.590000   0.010000   0.600000 (  0.602522)

## License

This project is released under the MIT license.

## Authors

* [Andrew Stone](http://github.com/stonean)
* [Fred Wu](http://github.com/fredwu)
* [Daniel Mendler](http://github.com/minad)

## Discuss

[Google Group](http://groups.google.com/group/slim-template)

## Slim related projects

* [Textmate bundle](http://github.com/fredwu/ruby-slim-textmate-bundle)
* [Rails 3 Generators](http://github.com/leogalmeida/slim-rails)
* [Slim for Clojure](http://github.com/chaslemley/slim.clj)
