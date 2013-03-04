# Translator/I18n

The translator plugin provides automatic translation of the templates using Gettext, Fast-Gettext or Rails I18n. Static text
in the template is replaced by the translated version.

Example:

    h1 Welcome to #{url}!

Gettext translates the string from english to german where interpolations are replaced by %1, %2, ...

    "Welcome to %1!" -> "Willkommen auf %1!"

and renders as

    <h1>Willkommen auf slim-lang.com!</h1>

Enable the translator plugin with

    require 'slim/translator'

# Options

<table>
<thead style="font-weight:bold"><tr><td>Type</td><td>Name</td><td>Default</td><td>Purpose</td></tr></thead>
<tbody>
<tr><td>Boolean</td><td>:tr</td><td>true</td><td>Enable translator (Enabled if 'slim/translator' is required)</td></tr>
<tr><td>Symbol</td><td>:tr_mode</td><td>:dynamic</td><td>When to translate: :static = at compile time, :dynamic = at runtime</td></tr>
<tr><td>String</td><td>:tr_fn</td><td>Depending on installed translation library</td><td>Translation function, could be '_' for gettext</td></tr>
</tbody>
</table>
