## Slim 

Slim is the result of cross breeding Haml and Ruhl resulting in a indention based, minimal markup, code restricting templating language.

## Why?

I think having your template language accept arbitrary code invites poor design.  I developed Ruhl as a test to see if I could make a typically static HTML document dynamic via a single data-ruhl attribute and minimal keywords.  Well, turns out, I could.  The only problem is that people don't like HTML.  It's not sexy and you have to close your own tags!  

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

        < yield

        - unless items.empty?
          table
            - for item in items do
              tr 
                td < item.name
                td < item.price
        - else
          p No items found

        div id="footer"
          Copyright &copy; 2010 Andrew Stone

        = render partial: 'tracking_code' 

        script
          $(content).do_something();


So some basic rules:

* Standard Ruby syntax after '<'
  * using end is not required
* A block object is always the local object.
  ** Methods don't need to be qualified, will go against block object first 
     then fall back

