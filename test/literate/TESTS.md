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
<body>
  Text
</body>
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

This is especially useful if you use tags behind a text block.

~~~ slim
' Link to
a href="http://slim-lang.com" slim-lang.com
~~~

renders as

~~~ html
Link to <a href="http://slim-lang.com">slim-lang.com</a>
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
<html><head><title>Example</title></head>
<body>
  yes
</body>
</html>
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

You can also write loops like this

~~~ slim
- items = [{name: 'table', price: 10}, {name: 'chair', price: 5}]
table#items
  - for item in items do
    tr
      td.name = item[:name]
      td.price = item[:price]
~~~

which renders as

~~~ html
<table id="items">
  <tr>
    <td class="name">
      table
    </td>
    <td class="price">
      10
    </td>
  </tr>
  <tr>
    <td class="name">
      chair
    </td>
    <td class="price">
      5
    </td>
  </tr>
</table>
~~~

The `do` keyword can be omitted.

~~~ slim
- items = [{name: 'table', price: 10}, {name: 'chair', price: 5}]
table#items
  - for item in items
    tr
      td.name = item[:name]
      td.price = item[:price]
~~~

which renders as

~~~ html
<table id="items">
  <tr>
    <td class="name">
      table
    </td>
    <td class="price">
      10
    </td>
  </tr>
  <tr>
    <td class="name">
      chair
    </td>
    <td class="price">
      5
    </td>
  </tr>
</table>
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

You don't need the explicit `\` if the line ends with a comma `,`.

~~~ slim
ruby:
  def test(*args)
    args.join('-')
  end
= test('arg1',
'arg2',
'arg3')
~~~

renders as

~~~ html
arg1-arg2-arg3
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

The equal sign with modifier `=>` produces dynamic output with a trailing white space.

~~~ slim
=> 7*7
~~~

renders as

~~~ html
49 
~~~

~~~ slim
=< 7*7
~~~

renders as

~~~ html
 49
~~~

The legacy syntax `='` is also supported.

~~~ slim
=' 7*7
~~~

renders as

~~~ html
49 
~~~

The equal sign with modifier `=<` produces dynamic output with a leading white space.

~~~ slim
=< 7*7
~~~

renders as

~~~ html
 49
~~~

The equal sign with modifiers `=<>` produces dynamic output with a leading and trailing white space.

~~~ slim
=<> 7*7
~~~

renders as

~~~ html
 49 
~~~

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

The double equal sign with modifier `==>` produces dynamic output without HTML escaping and trailing white space.

~~~ slim
==> '<script>evil();</script>'
~~~

renders as

~~~ html
<script>evil();</script> 
~~~

The legacy syntax `=='` is also supported.

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
  <p>
    Hello!
  </p>
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
  <p>
    Hello!
  </p>
  <!--First line determines indentation
  
  of the comment-->
</body>
~~~

### IE conditional comment `/[...]`

~~~ slim
/[if IE]
    p Get a better browser.
~~~

renders as

~~~ html
<!--[if IE]>
<p>
  Get a better browser.
</p>
<![endif]-->
~~~

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

You can close tags explicitly by appending a trailing `/`.

~~~ slim
div id="not-closed"
.closed/
#closed/
div id="closed"/
~~~

renders as

~~~ html
<div id="not-closed"></div>
<div class="closed" />
<div id="closed" />
<div id="closed" />
~~~

Note, that this is usually not necessary since the standard html tags (img, br, ...) are closed automatically.

~~~ slim
img src="image.png"
~~~

renders as

~~~ html
<img src="image.png" />
~~~

### Trailing and leading whitespace

You can force a trailing whitespace behind a tag by adding `>`. The legacy syntax with `'` is also supported.

~~~ slim
a#closed> class="test" /
a#closed> class="test"/
a> href='url1' Link1
a< href='url1' Link1
a' href='url2' Link2
~~~

renders as

~~~ html
<a class="test" id="closed" /> <a class="test" id="closed" /> <a href="url1">Link1</a>  <a href="url1">Link1</a><a href="url2">Link2</a> 
~~~

If you combine > and =' only one trailing whitespace is added.

~~~ slim
a> =' 'Text1'
a =' 'Text2'
a> = 'Text3'
a>= 'Text4'
a=> 'Text5'
a<= 'Text6'
a=< 'Text7'
~~~

renders as

~~~ html
<a>Text1</a> <a>Text2</a> <a>Text3</a> <a>Text4</a> <a>Text5</a>  <a>Text6</a> <a>Text7</a>
~~~

You can force a leading whitespace before a tag by adding `<`.

~~~ slim
a#closed< class="test" /
a#closed< class="test"/
a< href='url1' Link1
a< href='url2' Link2
~~~

~~~ html
 <a class="test" id="closed" /> <a class="test" id="closed" /> <a href="url1">Link1</a> <a href="url2">Link2</a>
~~~

You can also combine both.

~~~ slim
a#closed<> class="test" /
a#closed>< class="test"/
a<> href='url1' Link1
a<> href='url2' Link2
~~~

~~~ html
 <a class="test" id="closed" />  <a class="test" id="closed" />  <a href="url1">Link1</a>  <a href="url2">Link2</a> 
~~~

### Inline tags

Sometimes you may want to be a little more compact and inline the tags.

~~~ slim
ul
  li.first: a href="/first" First
  li: a href="/second" Second
~~~

renders as

~~~ html
<ul>
  <li class="first">
    <a href="/first">First</a>
  </li>
  <li>
    <a href="/second">Second</a>
  </li>
</ul>
~~~

For readability, don't forget you can wrap the attributes.

~~~ slim
ul
  li.first: a(href="/first") First
  li: a(href="/second") Second
~~~

renders as

~~~ html
<ul>
  <li class="first">
    <a href="/first">First</a>
  </li>
  <li>
    <a href="/second">Second</a>
  </li>
</ul>
~~~

### Text content

### Dynamic content `=`

### Attributes

#### Attribute wrapper

If a delimiter makes the syntax more readable for you, you can use the characters `{...}`, `(...)`, `[...]` to wrap the attributes.

~~~ slim
li
  a(href="http://slim-lang.com" class="important") Link
li
  a[href="http://slim-lang.com" class="important"] Link
li
  a{href="http://slim-lang.com" class="important"} Link
~~~

renders as

~~~ html
<li>
  <a class="important" href="http://slim-lang.com">Link</a>
</li>
<li>
  <a class="important" href="http://slim-lang.com">Link</a>
</li>
<li>
  <a class="important" href="http://slim-lang.com">Link</a>
</li>
~~~

If you wrap the attributes, you can spread them across multiple lines:

~~~ slim
a(href="http://slim-lang.com"

     class="important") Link
~~~

renders as

~~~ html
<a class="important" href="http://slim-lang.com">Link</a>
~~~

~~~ slim
dl(
  itemprop='address'
  itemscope
  itemtype='http://schema.org/PostalAddress'
)
~~~

renders as

~~~ html
<dl itemprop="address" itemscope="" itemtype="http://schema.org/PostalAddress"></dl>
~~~

You may use spaces around the wrappers and assignments:

~~~ slim
h1 id = "logo" Logo
h2 [ id = "tagline" ] Tagline
~~~

renders as

~~~ html
<h1 id="logo">
  Logo
</h1>
<h2 id="tagline">
  Tagline
</h2>
~~~

#### Quoted attributes

You can use single or double quotes for simple text attributes.

~~~ slim
a href="http://slim-lang.com" title='Slim Homepage' Goto the Slim homepage
~~~

renders as

~~~ html
<a href="http://slim-lang.com" title="Slim Homepage">Goto the Slim homepage</a>
~~~

You can use text interpolation in the quoted attributes:

~~~ slim
- url='slim-lang.com'
a href="http://#{url}" Goto the #{url}
a href="{"test"}" Test of quoted text in braces
~~~

renders as

~~~ html
<a href="http://slim-lang.com">Goto the slim-lang.com</a><a href="{&quot;test&quot;}">Test of quoted text in braces</a>
~~~

The attribute value will be escaped by default. Use == if you want to disable escaping in the attribute.

~~~ slim
li
  a href='&' Link
li
  a href=="&amp;" Link
~~~

renders as

~~~ html
<li>
  <a href="&amp;">Link</a>
</li>
<li>
  <a href="&amp;">Link</a>
</li>
~~~

You can use newlines in quoted attributes

~~~ slim
a data-title="help" data-content="extremely long help text that goes on
  and one and one and then starts over...." Link
~~~

renders as

~~~ html
<a data-content="extremely long help text that goes on
and one and one and then starts over...." data-title="help">Link</a>
~~~

You can break quoted attributes with an backslash `\`

~~~ slim
a data-title="help" data-content="extremely long help text that goes on\
  and one and one and then starts over...." Link
~~~

renders as

~~~ html
<a data-content="extremely long help text that goes on and one and one and then starts over...." data-title="help">Link</a>
~~~

#### Ruby attributes

Long ruby attributes can be broken with backslash `\`

~~~ slim
a href=1+\
   1 Link
~~~

renders as

~~~ html
<a href="2">Link</a>
~~~

You don't need the explicit `\` if the line ends with a comma `,`.

~~~ slim
ruby:
  def test(*args)
    args.join('-')
  end
a href=test('arg1',
'arg2',
'arg3') Link
~~~

renders as

~~~ html
<a href="arg1-arg2-arg3">Link</a>
~~~

#### Boolean attributes

The attribute values `true`, `false` and `nil` are interpreted as booleans.
If you use the attribut wrapper you can omit the attribute assigment.

~~~ slim
- true_value1 = ""
- true_value2 = true
input type="text" disabled=true_value1
input type="text" disabled=true_value2
input type="text" disabled="disabled"
input type="text" disabled=true
input(type="text" disabled)
~~~

renders as

~~~ html
<input disabled="" type="text" /><input disabled="" type="text" /><input disabled="disabled" type="text" /><input disabled="" type="text" /><input disabled="" type="text" />
~~~

~~~ slim
- false_value1 = false
- false_value2 = nil
input type="text" disabled=false_value1
input type="text" disabled=false_value2
input type="text"
input type="text" disabled=false
input type="text" disabled=nil
~~~

renders as

~~~ html
<input type="text" /><input type="text" /><input type="text" /><input type="text" /><input type="text" />
~~~

If html5 is activated the attributes are written as standalone.

~~~ options
:format => :html
~~~

~~~ slim
- true_value1 = ""
- true_value2 = true
input type="text" disabled=true_value1
input type="text" disabled=true_value2
input type="text" disabled="disabled"
input type="text" disabled=true
input(type="text" disabled)
~~~

renders as

~~~ html
<input disabled="" type="text"><input disabled type="text"><input disabled="disabled" type="text"><input disabled type="text"><input disabled type="text">
~~~

#### Attribute merging

You can configure attributes to be merged if multiple are given (See option `:merge_attrs`). In the default configuration
this is done for class attributes with the white space as delimiter.

~~~ slim
a.menu class="highlight" href="http://slim-lang.com/" Slim-lang.com
~~~

renders as

~~~ html
<a class="menu highlight" href="http://slim-lang.com/">Slim-lang.com</a>
~~~

You can also use an `Array` as attribute value and the array elements will be merged using the delimiter.

~~~ slim
- classes = [:alpha, :beta]
span class=["first","highlight"] class=classes First
span class=:second,:highlight class=classes Second
~~~

renders as

~~~ html
<span class="first highlight alpha beta">First</span><span class="second highlight alpha beta">Second</span>
~~~

#### Splat attributes `*`


#### Dynamic tags `*`

You can create completely dynamic tags using the splat attributes. Just create a method which returns a hash
with the :tag key.

~~~ slim
ruby:
  def a_unless_current
    @page_current ? {tag: 'span'} : {tag: 'a', href: 'http://slim-lang.com/'}
  end
- @page_current = true
*a_unless_current Link
- @page_current = false
*a_unless_current Link
~~~

renders as

~~~ html
<span>Link</span><a href="http://slim-lang.com/">Link</a>
~~~

### Shortcuts

#### Tag shortcuts

We add tag shortcuts by setting the option `:shortcut`.

~~~ options
:shortcut => {'c' => {tag: 'container'}, 'sec' => {tag:'section'}, '#' => {attr: 'id'}, '.' => {attr: 'class'} }
~~~

~~~ slim
sec: c.content Text
~~~

renders to

~~~ html
<section>
  <container class="content">Text</container>
</section>
~~~

#### Attribute shortcuts

We add `&` to create a shortcut for the input elements with type attribute by setting the option `:shortcut`.

~~~ options
:shortcut => {'&' => {tag: 'input', attr: 'type'}, '#' => {attr: 'id'}, '.' => {attr: 'class'} }
~~~

~~~ slim
&text name="user"
&password name="pw"
&submit.CLASS#ID
~~~

renders to

~~~ html
<input name="user" type="text" /><input name="pw" type="password" /><input class="CLASS" id="ID" type="submit" />
~~~

This is stupid, but you can also use multiple character shortcuts.

~~~ options
:shortcut => {'&' => {tag: 'input', attr: 'type'}, '#<' => {attr: 'id'}, '#>' => {attr: 'class'} }
~~~

~~~ slim
&text name="user"
&password name="pw"
&submit#>CLASS#<ID
~~~

renders to

~~~ html
<input name="user" type="text" /><input name="pw" type="password" /><input class="CLASS" id="ID" type="submit" />
~~~

You can also set multiple attributes per shortcut.

~~~ options
:shortcut => {'.' => {attr: %w(id class)} }
~~~

~~~ slim
.test
~~~

renders to

~~~ html
<div class="test" id="test"></div>
~~~

Shortcuts can also have multiple characters.

~~~ options
:shortcut => {'.' => {attr: 'class'}, '#' => {attr: 'id'}, '.#' => {attr: %w(class id)} }
~~~

~~~ slim
.#test
.test
#test
~~~

renders to

~~~ html
<div class="test" id="test"></div>
<div class="test"></div>
<div id="test"></div>
~~~

#### ID shortcut and class shortcut `.`

ID and class shortcuts can contain dashes.

~~~ slim
.-test text
#test- text
.--a#b- text
.a--test-123#--b text
~~~

renders as

~~~ html
<div class="-test">
  text
</div>
<div id="test-">
  text
</div>
<div class="--a" id="b-">
  text
</div>
<div class="a--test-123" id="--b">
  text
</div>
~~~

## Text interpolation

Use standard Ruby interpolation. The text will be html escaped by default.

~~~ slim
- user="John Doe <john@doe.net>"
h1 Welcome #{user}!
~~~

renders as

~~~ html
<h1>
  Welcome John Doe &lt;john@doe.net&gt;!
</h1>
~~~

## Pretty printing of XML

We can enable XML mode with

~~~ options
:format => :xml
~~~

~~~ slim
doctype xml
document
  closed-element/
  element(boolean-attribute)
    child attribute="value"
      | content
~~~

~~~ html
<?xml version="1.0" encoding="utf-8" ?>
<document>
  <closed-element />
  <element boolean-attribute="">
    <child attribute="value">
      content
    </child>
  </element>
</document>
~~~

## Embedded engines

## Configuring Slim

## Plugins
