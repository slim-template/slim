# Slim

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

Syntax highlight support for __Emacs__ is included in the `extra` folder. There are also [Vim](https://github.com/bbommarito/vim-slim) and [Textmate](https://github.com/fredwu/ruby-slim-tmbundle) plugins.

## Template Converters

For Haml, there is a [Haml2Slim converter](https://github.com/fredwu/haml2slim). Please check out the [issue tracker](https://github.com/stonean/slim/issues) to see the status of the varies converters.

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

#### `='`

> Same as the single equal sign (`=`), except that it adds a trailing whitespace.

#### `==`

> Same as the single equal sign (`=`), but does not go through the `escape_html` method.

#### `=='`

> Same as the double equal sign (`==`), except that it adds a trailing whitespace.

#### `/`

> Use the forward slash for ruby code comments - anything after it won't get displayed in the final render.

#### `/!`

> Use the forward slash immediately followed by an exclamation mark for html comments (`<!-- -->`).


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

    # Linux + Ruby 1.9.2, 1000 iterations

                          user     system      total        real
    (1) erb           0.680000   0.000000   0.680000 (  0.810375)
    (1) erubis        0.510000   0.000000   0.510000 (  0.547548)
    (1) fast erubis   0.530000   0.000000   0.530000 (  0.583134)
    (1) slim          4.330000   0.020000   4.350000 (  4.495633)
    (1) haml          4.680000   0.020000   4.700000 (  4.747019)
    (1) haml ugly     4.530000   0.020000   4.550000 (  4.592425)
    
    (2) erb           0.240000   0.000000   0.240000 (  0.235896)
    (2) erubis        0.180000   0.000000   0.180000 (  0.185349)
    (2) fast erubis   0.150000   0.000000   0.150000 (  0.154970)
    (2) slim          0.050000   0.000000   0.050000 (  0.046685)
    (2) haml          0.490000   0.000000   0.490000 (  0.497864)
    (2) haml ugly     0.420000   0.000000   0.420000 (  0.428596)
    
    (3) erb           0.030000   0.000000   0.030000 (  0.033979)
    (3) erubis        0.030000   0.000000   0.030000 (  0.030705)
    (3) fast erubis   0.040000   0.000000   0.040000 (  0.035229)
    (3) slim          0.040000   0.000000   0.040000 (  0.036249)
    (3) haml          0.160000   0.000000   0.160000 (  0.165024)
    (3) haml ugly     0.150000   0.000000   0.150000 (  0.146130)
    
    (4) erb           0.060000   0.000000   0.060000 (  0.059847)
    (4) erubis        0.040000   0.000000   0.040000 (  0.040770)
    (4) slim          0.040000   0.000000   0.040000 (  0.047389)
    (4) haml          0.190000   0.000000   0.190000 (  0.188837)
    (4) haml ugly     0.170000   0.000000   0.170000 (  0.175378)

    1. Uncached benchmark. Template is parsed every time.
       Activate this benchmark with slow=1.

    2. Cached benchmark. Template is parsed before the benchmark.
       The ruby code generated by the template engine might be evaluated every time.
       This benchmark uses the standard API of the template engine.

    3. Compiled benchmark. Template is parsed before the benchmark and
       generated ruby code is compiled into a method.
       This is the fastest evaluation strategy because it benchmarks
       pure execution speed of the generated ruby code.

    4. Compiled Tilt benchmark. Template is compiled with Tilt, which gives a more
       accurate result of the performance in production mode in frameworks like
       Sinatra, Ramaze and Camping. (Rails still uses its own template
       compilation.)

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

* [Vim files](https://github.com/bbommarito/vim-slim)
* [Textmate bundle](https://github.com/fredwu/ruby-slim-tmbundle)
* [Haml2Slim converter](https://github.com/fredwu/haml2slim)
* [Rails 3 Generators](https://github.com/leogalmeida/slim-rails)
* [Slim for Clojure](https://github.com/chaslemley/slim.clj)
