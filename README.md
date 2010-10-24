# Slim

Slim is a template language whose goal is to reduce the view syntax to the essential parts without becoming cryptic.


## What?

Slim is a fast, lightweight templating engine with support for __Rails 3__. It has been tested on Ruby 1.9.2 and Ruby/REE 1.8.7. Slim is heavily influenced by [Haml](http://github.com/nex3/haml) and [Jade](http://github.com/visionmedia/jade).

Slim is also integrated into [Tilt](http://github.com/rtomayko/tilt), so it can be used together with [Sinatra](http://github.com/sinatra/sinatra) or plain [Rack](http://github.com/rack/rack).

## Why?

Within the Rails community, _Erb_ and _Haml_ are without doubt the two most popular templating engines. However, _Erb_'s syntax is cumbersome and Haml's performance isn't exactly the best. Slim was born to bring the minimalist syntax approach of _Haml_ and the higher performance of Erb into once solution.

___Yes, Slim is speedy!___ Benchmarks are provided at the end of this README file. Alternatively, a benchmark rake task is provided so you could test it yourself (`rake bench`).


## How?

Install Slim as a gem:

    gem install slim

Include Slim in your Gemfile:

    gem 'slim'

In `config/application.rb`, add the following line near the top (i.e. just below `require 'rails/all'`):

    require 'slim/rails'

That's it!

If you want to use the Slim template directly, you can use the Tilt interface:

    Tilt.new['template.slim'].render(scope)
    Slim::Template.new(filename, optional_option_hash).render(scope)
    Slim::Template.new(optional_option_hash) { source }.render(scope)

## The syntax

As a Rails developer, you might already be very familiar with _Haml_'s syntax and you think it is fantastic - until you entered the magic kingdom of _node.js_ and got introduced to _Jade_.

Slim's syntax is inspired by both _Haml_ and _Jade_.

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

        = render partial: 'tracking_code'

        script
          | $(content).do_something();


## Language features

### Line indicators

__Please note that all line indicators must be followed by a space__

#### `|`

> The pipe tells Slim to just copy the line. It essentially escapes any processing.

#### `` ` `` or `'`

> _Same as the pipe (`|`)._

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
  `end` is not required but can be used if you don't want to omit it

#### Can put content on same line or nest it.
  If you nest content (e.g. put it on the next line), start the line with a pipe (`|`) or a backtick (`` ` ``).

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

  Or nest it.  __Note:__ Must use a pipe or a backtick (followed by a space) to escape processing

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

  Use a pipe (`|`) or backtick (`` ` ``) to start the escape.
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
    erb                    0.410000   0.010000   0.420000 (  0.421608)
    erubis                 0.350000   0.000000   0.350000 (  0.357187)
    fast erubis            0.340000   0.000000   0.340000 (  0.351943)
    slim                   2.360000   0.020000   2.380000 (  2.495331)
    haml                   2.970000   0.010000   2.980000 (  3.023121)
    haml ugly              2.870000   0.010000   2.880000 (  2.968662)
    erb (cached)           0.150000   0.000000   0.150000 (  0.149980)
    erubis (cached)        0.120000   0.000000   0.120000 (  0.122935)
    fast erubis (cached)   0.100000   0.000000   0.100000 (  0.105832)
    slim (cached)          0.020000   0.000000   0.020000 (  0.020290)
    haml (cached)          0.330000   0.000000   0.330000 (  0.335519)
    haml ugly (cached)     0.280000   0.000000   0.280000 (  0.286695)

    # OS X 10.6 + REE 1.8.7

                               user     system      total        real
    erb                    0.440000   0.010000   0.450000 (  0.463941)
    erubis                 0.310000   0.000000   0.310000 (  0.322083)
    fast erubis            0.310000   0.000000   0.310000 (  0.309852)
    slim                   2.420000   0.020000   2.440000 (  2.470208)
    haml                   2.990000   0.020000   3.010000 (  3.040942)
    haml ugly              2.900000   0.020000   2.920000 (  3.101786)
    erb (cached)           0.080000   0.000000   0.080000 (  0.079252)
    erubis (cached)        0.070000   0.000000   0.070000 (  0.066370)
    fast erubis (cached)   0.060000   0.000000   0.060000 (  0.062001)
    slim (cached)          0.030000   0.000000   0.030000 (  0.023835)
    haml (cached)          0.270000   0.010000   0.280000 (  0.279409)
    haml ugly (cached)     0.210000   0.000000   0.210000 (  0.221059)

    # OSX 10.6 + JRuby 1.5.3

                               user     system      total        real
    erb                    0.970000   0.000000   0.970000 (  0.970000)
    erubis                 0.672000   0.000000   0.672000 (  0.672000)
    fast erubis            0.624000   0.000000   0.624000 (  0.624000)
    slim                   2.694000   0.000000   2.694000 (  2.694000)
    haml                   3.368000   0.000000   3.368000 (  3.368000)
    haml ugly              3.462000   0.000000   3.462000 (  3.462000)
    erb (cached)           0.736000   0.000000   0.736000 (  0.736000)
    erubis (cached)        0.413000   0.000000   0.413000 (  0.413000)
    fast erubis (cached)   0.340000   0.000000   0.340000 (  0.340000)
    slim (cached)          0.069000   0.000000   0.069000 (  0.069000)
    haml (cached)          1.001000   0.000000   1.001000 (  1.001000)
    haml ugly (cached)     0.763000   0.000000   0.763000 (  0.763000)

## Authors

* [Andrew Stone](http://github.com/stonean)
* [Fred Wu](http://github.com/fredwu)

## Discuss

[Google Group](http://groups.google.com/group/slim-template)
