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

### Wrap attributes with delimiters

    # If a delimiter makes the syntax more readable for you,
    # you can use any non-word and non-space characters except:
    # equal sign (=), hash (#) and dot (.)

    body
      h1(id="logo") = page_logo
      h2[id="tagline" class="small tagline"] = page_tagline

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

    # Ubuntu 10.04 + Ruby 1.9.2

                               user     system      total        real
    erb                    0.560000   0.010000   0.570000 (  0.574373)
    erubis                 0.480000   0.000000   0.480000 (  0.501512)
    fast erubis            0.470000   0.000000   0.470000 (  0.481918)
    slim                   0.610000   0.000000   0.610000 (  0.612794)
    haml                   3.930000   0.010000   3.940000 (  3.939419)
    haml ugly              3.790000   0.010000   3.800000 (  3.798528)
    erb (cached)           0.190000   0.000000   0.190000 (  0.188593)
    erubis (cached)        0.160000   0.000000   0.160000 (  0.159869)
    fast erubis (cached)   0.140000   0.000000   0.140000 (  0.135476)
    slim (cached)          0.150000   0.000000   0.150000 (  0.153698)
    haml (cached)          0.430000   0.000000   0.430000 (  0.436980)
    haml ugly (cached)     0.370000   0.000000   0.370000 (  0.372770)

    # OS X 10.6 + Ruby 1.9.2

                               user     system      total        real
    erb                    0.390000   0.000000   0.390000 (  0.399811)
    erubis                 0.330000   0.010000   0.340000 (  0.331172)
    fast erubis            0.330000   0.000000   0.330000 (  0.332800)
    slim                   0.400000   0.010000   0.410000 (  0.399947)
    haml                   2.650000   0.020000   2.670000 (  2.684864)
    haml ugly              2.550000   0.020000   2.570000 (  2.592307)
    erb (cached)           0.150000   0.000000   0.150000 (  0.158407)
    erubis (cached)        0.140000   0.000000   0.140000 (  0.163568)
    fast erubis (cached)   0.110000   0.000000   0.110000 (  0.143785)
    slim (cached)          0.130000   0.010000   0.140000 (  0.147570)
    haml (cached)          0.310000   0.000000   0.310000 (  0.338857)
    haml ugly (cached)     0.270000   0.000000   0.270000 (  0.286244)

    # OS X 10.6 + REE 1.8.7

                               user     system      total        real
    erb                    0.470000   0.000000   0.470000 (  0.474660)
    erubis                 0.330000   0.000000   0.330000 (  0.339252)
    fast erubis            0.330000   0.000000   0.330000 (  0.339410)
    slim                   0.510000   0.000000   0.510000 (  0.521215)
    haml                   3.090000   0.030000   3.120000 (  3.167278)
    haml ugly              2.950000   0.020000   2.970000 (  2.989357)
    erb (cached)           0.080000   0.000000   0.080000 (  0.077019)
    erubis (cached)        0.070000   0.000000   0.070000 (  0.069950)
    fast erubis (cached)   0.070000   0.000000   0.070000 (  0.061986)
    slim (cached)          0.060000   0.000000   0.060000 (  0.063628)
    haml (cached)          0.260000   0.010000   0.270000 (  0.271184)
    haml ugly (cached)     0.230000   0.000000   0.230000 (  0.238252)


## Authors

* [Andrew Stone](http://github.com/stonean)
* [Fred Wu](http://github.com/fredwu)

## Discuss

[Google Group](http://groups.google.com/group/slim-template)
