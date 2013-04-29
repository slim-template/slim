# Smart text

The easiest way to combine text and markup is to use the <a name="smarttext">smart text mode</a>.

Enable the smart text plugin with

    require 'slim/smart'

This automatically enables the `:implicit_text` option as well,
so you can easily type text like this:

    p
      This is text.
      So is this,
        and it spans
        several lines.

As long as you leave the `:smart_text_escaping` enabled,
any non-verbatim text is automatically escaped for you.
However, for your convenience, any HTML entities detected are still used verbatim.
This way you are most likely to get what you really wanted,
without having to worry about HTML escaping all the time.

    h1 Questions & Answers
    footer
      Copyright &copy; #{Time.now.year}

Another cool thing about smart text is that it mixes fairly well with markup.
Smart text lines normally preserve newlines,
so it is easy to mix them with other tags, like emphasis or links:

    p
      > Your credit card
      strong will not
      > be charged now.
    p
      Check
      a href=r(:faq) our FAQ
      > for more info.

However, sometimes you do not want the whitespace around the inline tag.
Fortunately smart text takes care of the most common cases for you as well.
The leading newline is suppressed if the smart text block begins
with a character from the `:smart_text_begin_chars` set (`,.;:!?)]}` by default).
Similarly, trailing newline is suppressed if the smart text block ends
with a character from the `:smart_text_end_chars` set (`([{` by default).
This makes it quite easy to mix normal text with links or spans like this:

    p
      Please proceed to
      a href="/" our homepage
      .
    p
      Status: failed (
      a href="#1" details
      ).

Note that smart text is smart enough to know about tag shortcuts, too,
so it will correctly deal even with cases like this:

    .class
      #id
        #{'More'}
        i text
        ...

Of course, all this is meant only to make working with short text snippets more convenient.
For bulk text content, you are more than welcome to use one of the builtin embedded engines,
such as Markdown or Textile.

## Options

<table>
<thead style="font-weight:bold"><tr><td>Type</td><td>Name</td><td>Default</td><td>Purpose</td></tr></thead>
<tbody>
<tr><td>Boolean</td><td>:smart_text</td><td>true</td><td>Enable smart text mode newline processing</td></tr>
<tr><td>String</td><td>:smart_text_begin_chars</td><td>',.;:!?)]}'</td><td>Characters suppressing leading newline in smart text</td></tr>
<tr><td>String</td><td>:smart_text_end_chars</td><td>'([{'</td><td>Characters suppressing trailing newline in smart text</td></tr>
<tr><td>Boolean</td><td>:smart_text_escaping</td><td>true</td><td>When set, HTML characters which need escaping are automatically escaped in smart text</td></tr>
</tbody>
</table>
