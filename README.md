# Slim

Slim is a template language whose goal is reduce the syntax to the essential parts without becoming cryptic.

## What?

Slim is a Rails 3, Ruby 1.9.2 templating option.  I do not intend on making a Rails 2.x compatible version.  I don't think it would be difficult, so if you want it, I will happily accept contributions with tests.

## Why?

Simply put, I wanted to see if I could pull of a template language that required minimum use of special characters and at least matched Erb's speed.  Yes, Slim is speedy.

## How?

Include Slim in your Gemfile:

    gem 'slim'

In `config/application.rb`, add the following line near the top:

    require 'slim/rails'

That's it!

### The syntax

I actually like the indentation and tag closing nature of Haml.  I don't like the overall result of the markup though, it's a little cryptic.  I'm sure, with practice, people read it like the Matrix, but it's never suited me.  So why not try to improve it for me?  There may be one or two other people with the same thoughts.


So here's what I came up with:

    ! doctype html
    html
      head
        title Slim Examples
        meta name="keywords" content="template language"
      body
        h1 Markup examples
        div id="content" class="example1"
          p Nest by indentation

        = yield

        - unless items.empty?
          table
            - for item in items do
              tr
                td
                  = item.name
                td
                  = item.price
        - else
          p No items found

        div id="footer"
          | Copyright &copy; 2010 Andrew Stone

        = render partial: 'tracking_code'

        script
          | $(content).do_something();


### How do I?

#### Add content to a tag

    # Either start on the same line as the tag

    body
      h1 id="headline" Welcome to my site.

    # Or nest it.  __Note:__ Must use a pipe or a backtick (followed by a space) to escape processing

    body
      h1 id="headline"
        | Welcome to my site.

#### Add content to a tag with code

    # Can make the call on the same line

    body
      h1 id="headline" = page_headline

    # Or nest it.

    body
      h1 id="headline"
        = page_headline

#### Shortcut form for `id` and `class` attributes

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

#### Set an attribute's value with a method?

    # Use standard Ruby interpolation.

    body
      table
        - for user in users do
          tr id="user_#{user.id}"

#### Call a method in content

    # Use standard Ruby interpolation.

    body
      h1 Welcome #{current_user.name} to the show.

    # To escape the interpolation (i.e. render as is)

    body
      h1 Welcome \#{current_user.name} to the show.

#### Escape the escaping?

    # Use a double equal sign

    body
      h1 id="headline"
        == page_headline

#### Treat multiple lines of code as text that should bypass parsing.

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

#### Add ruby code comments?

    # Use a forward slash for ruby code comments
    
    body
      p
        / This line won't get displayed.
        / Neither does this line.
    
    # The parsed result of the above:
    
    <body><p></p></body>

### Things to know:

* Standard Ruby syntax after '-' and '='
  * __end__ is not required
* Can put content on same line or nest it.
  * If you nest content (e.g. put it on the next line), start the line with a pipe ('|') or a backtick ('`').
* Indentation matters, but it's not as strict as Haml.
  * If you want to indent 2 spaces, then 5.  It's your choice. To nest markup you only need to indent by one space, the rest is gravy.


### Line indicators:
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
  * This is a directive.  Most common example:
        ` ! doctype html renders  <!doctype html> `
* /
  * Use the forward slash for ruby code comments - anything after it won't get displayed in the final render.


### Please add feature requests and bugs to the Github issue tracker.
