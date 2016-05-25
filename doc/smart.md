# Smart text

The <a name="smarttext">smart text plugin</a> was created to simplify the typing and combining of text and markup in Slim templates.
Using the plugin gives you:

* More convenient ways to type text in Slim templates.
* Smarter and more consistent HTML escaping of typed text.
* Easier combining of the text with inline HTML tags with smart handling of whitespace on the boundaries.

To get started, enable the smart text plugin with

    require 'slim/smart'

First of all, this automatically enables the `:implicit_text` option.
When enabled, Slim will treat any line which doesn't start
with a lowercase tag name or any of the special characters as an implicit text line.
If the text needs to span several lines, indent them as usual.

This allows you to easily type text like this, without any leading indicator:

    This is an implicit text.
    This is a text
      which spans
      several lines.
    This is yet another text.

This works in addition to ways already available in stock Slim:

    p This is an inline text.
    p This is an inline text
      which spans multiple lines.
    | This is a verbatim text.
    | This is a verbatim text
      which spans multiple lines.
    <p>This is in fact a verbatim text as well.</p>

You can also mark the text explicitly with a leading `>`.
This is used for example when the text starts with a lowercase letter or an unusual character,
or merely for aesthetic consistency when it spans several lines.
It may be also needed if you want to use uppercase tag names
and therefore need to keep the `:implicit_text` option disabled.

    > This is an explicit text.
    > This is an explicit text
      which spans
      several lines.
    > 'This is a text, too.'

    > This is another way
    > of typing text which spans
    > several lines, if you prefer that.

BTW, all these examples can be pasted to `slimrb -r slim/smart` to see how the generated output looks like.

The plugin also improves upon Slim's automatic HTML escaping.
As long as you leave the `:smart_text_escaping` enabled,
any non-verbatim text (i.e., any implicit, explicit, and inline text) is automatically escaped for you.
However, for your convenience, any HTML entities detected are still used verbatim.
This way you are most likely to get what you really wanted,
without having to worry about HTML escaping all the time.

    h1 Questions & Answers
    footer
      Copyright &copy; #{Time.now.year}

Another cool thing about the plugin is that it makes text mix fairly well with markup.
The text lines are made to preserve newlines as needed,
so it is easy to mix them with other tags, like emphasis or links:

    p
      Your credit card
      strong will not
      > be charged now.
    p
      Check
      a href='/faq' our FAQ
      > for more info.

(Note the use of the explicit text indicator `>` to distinguish lowercase text from tags).

However, sometimes you do not want any whitespace around the inline tag at all.
Fortunately the plugin takes care of the most common cases for you as well.
The newline before the tag is suppressed if the preceding line ends
with a character from the `:smart_text_end_chars` set (`([{` by default).
Similarly, the newline after the tag is suppressed if the following line begins
with a character from the `:smart_text_begin_chars` set (`,.;:!?)]}` by default).
This makes it quite easy to naturally mix normal text with links or spans like this:

    p
      Please proceed to
      a href="/" our homepage
      .
    p
      Status: failed (
      a href="#1" see details
      ).

Note that the plugin is smart enough to know about tag shortcuts, too,
so it will correctly deal even with cases like this:

    .class
      #id
        #{'More'}
        i text
        ...

And that's it.
Of course, all this is meant only to make working with short text snippets more convenient.
For bulk text content, you are more than welcome to use one of the builtin embedded engines,
such as Markdown or Textile.

## Options

| Type | Name | Default | Purpose |
| ---- | ---- | ------- | ------- |
| Boolean | :implicit_text | true | Enable implicit text recognition |
| Boolean | :smart_text | true | Enable smart text mode newline processing |
| String | :smart_text_begin_chars | ',.;:!?)]}' | Characters suppressing leading newline in smart text |
| String | :smart_text_end_chars | '([{' | Characters suppressing trailing newline in smart text |
| Boolean | :smart_text_escaping | true | When set, HTML characters which need escaping are automatically escaped in smart text |
