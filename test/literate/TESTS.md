# Slim test suite

You can run this testsuite with `rake test:literate`.

We use pretty mode in the test suite to make the output more readable. Pretty mode
is enabled by setting the option

~~~ options
:pretty => true
~~~

## Line indicators

In this section we test all line indicators.

### Text `|`

A text blocks starts with the `|` as line indicator.

~~~ slim
| Text block
~~~

renders as

~~~ html
Text block
~~~

Multiple lines can be indented beneath the first text line.

~~~ slim
|  Text
    block

     with

    multiple
   lines
~~~

renders as

~~~ html
 Text
  block

   with

  multiple
 lines
~~~

The first line of a text block determines the indentation.

~~~ slim
|

   Text
    block

     with

    multiple
   lines
~~~

renders as

~~~ html
Text
 block

  with

 multiple
lines
~~~

You can nest text blocks beneath tags.

~~~ slim
body
  | Text
~~~

renders as

~~~ html
<body>Text</body>
~~~

You can embed html code in the text which is not escaped.

~~~ slim
| <a href="http://slim-lang.com">slim-lang.com</a>
~~~

renders as

~~~ html
<a href="http://slim-lang.com">slim-lang.com</a>
~~~

### Text with trailing white space `'`

A text blocks with trailing white space starts with the `'` as line indicator.

~~~ slim
' Text block
~~~

renders as

~~~ html
Text block 
~~~

Multiple lines can be indented beneath the first text line.

~~~ slim
'  Text
    block

     with

    multiple
   lines
~~~

renders as

~~~ html
 Text
  block

   with

  multiple
 lines 
~~~

The first line of a text block determines the indentation.

~~~ slim
'

   Text
    block

     with

    multiple
   lines
~~~

renders as

~~~ html
Text
 block

  with

 multiple
lines 
~~~

### Inline HTML `<`

HTML can be written directly.

~~~ slim
<a href="http://slim-lang.com">slim-lang.com</a>
~~~

renders as

~~~ html
<a href="http://slim-lang.com">slim-lang.com</a>
~~~

HTML tags allow nested blocks inside.

~~~ slim
<html>
  <head>
    title Example
  </head>
  body
    - if true
      | yes
    - else
      | no
</html>
~~~

renders as

~~~ html
<html><head><title>Example</title></head><body>yes</body></html>
~~~

### Control code `-`

The dash `-` denotes arbitrary control code.

~~~ slim
- greeting = 'Hello, World!'
- if false
  | Not true
- else
  = greeting
~~~

renders as

~~~ html
Hello, World!
~~~

Complex code can be broken with backslash `\`.

~~~ slim
- greeting = 'Hello, '+\
     \
    'World!'
- if false
  | Not true
- else
  = greeting
~~~

renders as

~~~ html
Hello, World!
~~~

### Output `=`

The equal sign `=` produces dynamic output.

~~~ slim
= 7*7
~~~

renders as

~~~ html
49
~~~

Dynamic output is escaped by default.

~~~ slim
= '<script>evil();</script>'
~~~

renders as

~~~ html
&lt;script&gt;evil();&lt;/script&gt;
~~~

Long code lines can be broken with `\`.

~~~ slim
= (0..10).map do |i|\
  2**i \
end.join(', ')
~~~

renders as

~~~ html
1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024
~~~

You can also disable HTML escaping globally by setting the option

~~~ options
:disable_escape => true
~~~

~~~ slim
= '<script>evil();</script>'
~~~

renders as

~~~ html
<script>evil();</script>
~~~

### Output with trailing white space `='`

### Output without HTML escaping `==`

The double equal sign `==` produces dynamic output without HTML escaping.

~~~ slim
== '<script>evil();</script>'
~~~

renders as

~~~ html
<script>evil();</script>
~~~

The option option

~~~ options
:disable_escape => true
~~~

doesn't affect the output of `==`.

~~~ slim
== '<script>evil();</script>'
~~~

renders as

~~~ html
<script>evil();</script>
~~~

### Output without HTML escaping and trailing ws `=='`


The double equal sign with apostrophe `=='` produces dynamic output without HTML escaping and trailing white space.

~~~ slim
==' '<script>evil();</script>'
~~~

renders as

~~~ html
<script>evil();</script> 
~~~

The option option

~~~ options
:disable_escape => true
~~~

doesn't affect the output of `==`.

~~~ slim
==' '<script>evil();</script>'
~~~

renders as

~~~ html
<script>evil();</script> 
~~~

### Code comment `/`

Code comments begin with `/` and produce no output.

~~~ slim
/ Comment
body
  / Another comment
    with

    multiple lines
  p Hello!
~~~

renders as

~~~ html
<body>
  <p>Hello!</p>
</body>
~~~

### HTML comment `/!`

Code comments begin with `/!`.

~~~ slim
/! Comment
body
  /! Another comment
     with multiple lines
  p Hello!
  /!
      First line determines indentation

      of the comment
~~~

renders as

~~~ html
<!--Comment-->
<body>
  <!--Another comment
  with multiple lines-->
  <p>Hello!</p>
  <!--First line determines indentation
  
  of the comment-->
</body>
~~~

### IE conditional comment `/[...]`

## HTML tags

### Doctype tags

The doctype tag is a special tag which can be used to generate the complex doctypes in a very simple way.

You can output the XML version using the doctype tag.

~~~ slim
doctype xml
doctype xml ISO-8859-1
~~~

renders as

~~~ html
<?xml version="1.0" encoding="utf-8" ?>
<?xml version="1.0" encoding="iso-8859-1" ?>
~~~

In XHTML mode the following doctypes are supported:

~~~ slim
doctype html
doctype 5
doctype 1.1
doctype strict
doctype frameset
doctype mobile
doctype basic
doctype transitional
~~~

renders as

~~~ html
<!DOCTYPE html>
<!DOCTYPE html>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">
<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN" "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
~~~

If we activate HTML mode with the option

~~~ options
:format => :html
~~~

the following doctypes are supported:

~~~ slim
doctype html
doctype 5
doctype strict
doctype frameset
doctype transitional
~~~

renders as

~~~ html
<!DOCTYPE html>
<!DOCTYPE html>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
~~~

### Closed tags

### Inline tags

### Text content

### Dynamic content `=`

### Attributes

#### Attribute wrapper

#### Quoted attributes

#### Ruby attributes

#### Boolean attributes

#### Attribute merging

#### Splat attributes `*`

#### ID shortcut and class shortcut `.`

#### Attribute shortcuts

## Text interpolation

## Embedded engines
