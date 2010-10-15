# Slim

Slim is a template language whose goal is to reduce the view syntax to the essential parts without becoming cryptic.


## What?

Slim is a fast, lightweight templating engine for __Rails 3__. It has been tested on Ruby 1.9.2 and Ruby/REE 1.8.7. Slim is heavily influenced by [Haml](http://github.com/nex3/haml) and [Jade](http://github.com/visionmedia/jade).


## Why?

Within the Rails community, _Erb_ and _Haml_ are without doubt the two most popular templating engines. However, _Erb_'s syntax is cumbersome and Haml's performance isn't exactly the best. Slim was born to bring the minimalist syntax approach of _Haml_ and the higher performance of Erb into once solution.

___Yes, Slim is speedy!___ Benchmarks are provided at the end of this README file. Alternatively, a benchmark script is provided so you could test it yourself (`./benchmarks/run.rb`).


## How?

Install Slim as a gem:

    gem install slim

Include Slim in your Gemfile:

    gem 'slim'

In `config/application.rb`, add the following line near the top (i.e. just below `require 'rails/all'`):

    require 'slim/rails'

That's it!


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

* |
  * The pipe tells Slim to just copy the line. It essentially escapes any processing.
* `
  * _Same as the pipe ('|')._
* -
  * The dash denotes control code (similar to Haml).  Examples of control code are loops and conditionals.
* =
  * The equal sign tells Slim it's a Ruby call that produces output to add to the buffer (similar to Erb and Haml).
* ==
  * Same as the single equal sign, but does not go through the escape_html method.
* !
  * This is a directive.  Most common example: `! doctype html # renders <!doctype html>`
* /
  * Use the forward slash for ruby code comments - anything after it won't get displayed in the final render.

### Things to know

* Standard Ruby syntax after '-' and '='
  * __end__ is not required
* Can put content on same line or nest it.
  * If you nest content (e.g. put it on the next line), start the line with a pipe ('|') or a backtick ('`').
* Indentation matters, but it's not as strict as Haml.
  * If you want to first indent 2 spaces, then 5 spaces, it's your choice. To nest markup you only need to indent by one space, the rest is gravy.

### Add content to a tag

    # Either start on the same line as the tag

    body
      h1 id="headline" Welcome to my site.

    # Or nest it.  __Note:__ Must use a pipe or a backtick (followed by a space) to escape processing

    body
      h1 id="headline"
        | Welcome to my site.

### Add content to a tag with code

    # Can make the call on the same line

    body
      h1 id="headline" = page_headline

    # Or nest it.

    body
      h1 id="headline"
        = page_headline

### Shortcut form for `id` and `class` attributes

    # Similarly to Haml, you can specify the `id` and `class`
    # attributes in the following shortcut form
    # Note: the shortcut form does not evaluate ruby code

    body
      h1#headline
        = page_headline
      h2#tagline.small.tagline
        = page_tagline
      .content
        = show_content

    # this is the same as

    body
      h1 id="headline"
        = page_headline
      h2 id="tagline" class="small tagline"
        = page_tagline
      div class="content"
        = show_content

### Set an attribute's value with a method

    # Use standard Ruby interpolation.

    body
      table
        - for user in users do
          tr id="user_#{user.id}"

### Call a method in content

    # Use standard Ruby interpolation.

    body
      h1 Welcome #{current_user.name} to the show.

    # To escape the interpolation (i.e. render as is)

    body
      h1 Welcome \#{current_user.name} to the show.

### Skip the escaping

    # Use a double equal sign

    body
      h1 id="headline"
        == page_headline

### Treat multiple lines of code as text that should bypass parsing

    # Use a pipe ('|') or backtick ('`') to start the escape.  
    # Each following line that is indented greater than 
    # the backtick is copied over.

    body
      p
        |
          This is a test of the text block.

    # The parsed result of the above:

    <body><p>This is a test of the text block.</p></body>

    # The left margin is set at the indent of the backtick + one space.
    # Any additional spaces will be copied over.

    body
      p
        |
          This line is on the left margin.
           This line will have one space in front of it.
             This line will have two spaces in front of it.
               And so on...

### Add code comments

    # Use a forward slash for ruby code comments
    
    body
      p
        / This line won't get displayed.
        / Neither does this line.
    
    # The parsed result of the above:
    
    <body><p></p></body>


## Benchmarks

    # OS X 10.6 + REE 1.8.7

                            user     system      total        real
    erb                 0.500000   0.000000   0.500000 (  0.516644)
    slim                0.550000   0.000000   0.550000 (  0.579362)
    haml                3.390000   0.050000   3.440000 (  3.669325)
    mustache            1.130000   0.040000   1.170000 (  1.213134)
    erb (cached)        0.090000   0.000000   0.090000 (  0.099274)
    slim (cached)       0.080000   0.000000   0.080000 (  0.079823)
    haml (cached)       0.290000   0.000000   0.290000 (  0.312542)
    mustache (cached)   0.080000   0.000000   0.080000 (  0.079184)

    # OS X 10.6 + Ruby 1.9.2

                            user     system      total        real
    erb                 0.400000   0.000000   0.400000 (  0.431967)
    slim                0.410000   0.010000   0.420000 (  0.425059)
    haml                3.030000   0.030000   3.060000 (  3.199970)
    mustache            1.360000   0.030000   1.390000 (  1.435129)
    erb (cached)        0.150000   0.000000   0.150000 (  0.157284)
    slim (cached)       0.130000   0.010000   0.140000 (  0.129576)
    haml (cached)       0.320000   0.000000   0.320000 (  0.344316)
    mustache (cached)   0.040000   0.000000   0.040000 (  0.049058)

## Authors

* [Andrew Stone](http://github.com/stonean)
* [Fred Wu](http://github.com/fredwu)