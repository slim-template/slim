## Slim 

Slim is a template language whose goal is reduce the syntax to the essential parts without becoming cryptic.  

## What?

Slim is a Rails 3, Ruby 1.9.2 templating option.  I do not intend on making a Rails 2.x compatible version.  I don't think it would be difficult, so if you want it, I will happily accept contributions with tests.

## Why?

Simply put, I wanted to see if I could pull of a template language that required minimum use of special characters and at least matched Erb's speed.  Yes, Slim is speedy.

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
          ` Copyright &copy; 2010 Andrew Stone

        = render partial: 'tracking_code' 

        script
          ` $(content).do_something();


### How do I?

#### Add content to a tag

      # Either start on the same line as the tag

      body
        h1 id="headline" Welcome to my site.

      # Or nest it.  __Note:__ Must use backtick (with following space) to escape processing

      body
        h1 id="headline" 
          ` Welcome to my site.

#### Set an attribute's value with a method?

      # Just use standard Ruby interpolation.

      body
        table 
          - for user in users do 
            tr id="user_#{user.id}"
          

### Things to know:

* Standard Ruby syntax after '-' and '='
  * __end__ is not required
  * Ruby code must be on it's own line (__TODO:__ allow inline)
  * If you're making a method call, wrap the arguments in parenthesis (__TODO:__ make this a non requirement)
* Can put content on same line or nest it.
  * If you nest content (e.g. put it on the next line), start the line with a backtick ('`')
* Indentation matters, but it's not as strict as Haml.
  * If you want to indent 2 spaces, then 5.  It's your choice. To nest markup you only need to indent by one space, the rest is gravy.


### Line indicators:
  __Please note that all line indicators must be followed by a space__

* ` 
  * The backtick tells Slim to just copy the line.  It essentially escapes any processing.
* -
  * The dash denotes control code (similar to Haml).  Examples of control code are loops and conditionals.
* =
  * The equal sign tells Slim it's a Ruby call that produces output to add to the buffer (similar to Erb and Haml). 
* !
  * This is a directive.  Most common example:
        ` ! doctype html renders  <!doctype html> `


### Please add feature requests and bugs to the Github issue tracker.
