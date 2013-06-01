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

| Type | Name | Default | Purpose |
| ---- | ---- | ------- | ------- |
| Boolean | :tr | true | Enable translator (Enabled if 'slim/translator' is required) |
| Symbol | :tr_mode | :dynamic | When to translate: :static = at compile time, :dynamic = at runtime |
| String | :tr_fn | Depending on installed translation library | Translation function, could be '_' for gettext |
