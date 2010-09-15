## Slim 

Slim is a template language whose goal is reduce the syntax to the essential parts without becoming cryptic.

## Why?

I actually like the indentation and tag closing nature of Haml.  I don't like the overall result of the view, it takes work to decipher.  I'm sure, with practice, people read it like the Matrix, but it's never suited me.  So why not try to improve it for me?  There may be one or two other people with the same thoughts.


So here's what I'm looking to achieve:

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


So some basic rules:

* Standard Ruby syntax after '-' and '='
  * using end is not required
* Can put content on same line or nest it.

