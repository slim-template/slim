# Logic less mode

Logic less mode is inspired by [Mustache](https://github.com/defunkt/mustache). Logic less mode uses a dictionary object
e.g. a recursive hash tree which contains the dynamic content.

## Conditional

If the object is not false or empty?, the content will show

    - article
      h1 = title

## Inverted conditional

If the object is false or empty?, the content will show

    -! article
      p Sorry, article not found

## Iteration

If the object is an array, the section will iterate

    - articles
      tr: td = title

## Lambdas

Like mustache, Slim supports lambdas.

    = person
      = name

The lambda method could be defined like this

    def lambda_method
      "<div class='person'>#{yield(name: 'Andrew')}</div>"
    end

You can optionally pass one or more hashes to `yield`. If you pass multiple hashes, the block will be iterated as described above.

## Dictionary access

Example code:

    - article
      h1 = title

The dictionary object is accessed in the order given by the `:dictionary_access`. Default order:

1. `:symbol` - If `article.respond_to?(:has_key?)` and `article.has_key?(:title)`, Slim will execute `article[:title]`
2. `:string` - If `article.respond_to?(:has_key?)` and `article.has_key?('title')`, Slim will execute `article['title']`
3. `:method` - If `article.respond_to?(:title)`, Slim will execute `article.send(:title)`
4. `:instance_variable` - If `article.instance_variable_defined?(@title)`, Slim will execute `article.instance_variable_get @title`

If all the above fails, Slim will try to resolve the title reference in the same order against the parent object. In this example, the parent would be the dictionary object you are rendering the template against.

As you might have guessed, the article reference goes through the same steps against the dictionary. Instance variables are not allowed in the view code, but Slim will find and use them. Essentially, you're just dropping the @ prefix in your template. Parameterized method calls are not allowed.


## Strings

The `self` keyword will return the `.to_s` value for the element under consideration.

Given

    {
      article: [
        'Article 1',
        'Article 2'
      ]
    }

And

    - article
      tr: td = self

This will yield

    <tr>
      <td>Article 1</td>
    </>
    <tr>
      <td>Article 2</td>
    </tr>


## Logic less in Rails

Install:

    $ gem install slim

Require:

    gem 'slim', require: 'slim/logic_less'

You might want to activate logic less mode only for a few actions, you should disable logic-less mode globally at first in the configuration

    Slim::Engine.set_options logic_less: false

and activate logic less mode per render call in your action

    class Controller
      def action
        Slim::Engine.with_options(logic_less: true) do
          render
        end
      end
    end

## Logic less in Sinatra

Sinata has built-in support for Slim. All you have to do is require the logic less Slim plugin. This can be done in your config.ru:

    require 'slim/logic_less'

You are then ready to rock!

You might want to activate logic less mode only for a few actions, you should disable logic-less mode globally at first in the configuration

    Slim::Engine.set_options logic_less: false

and activate logic less mode per render call in your application

    get '/page'
      slim :page, logic_less: true
    end

## Options

| Type | Name | Default | Purpose |
| ---- | ---- | ------- | ------- |
| Boolean | :logic_less | true | Enable logic less mode (Enabled if 'slim/logic_less' is required) |
| String | :dictionary | "self" | Dictionary where variables are looked up |
| Symbol/Array&lt;Symbol&gt; | :dictionary_access | [:symbol, :string, :method, :instance_variable] | Dictionary access order (:symbol, :string, :method, :instance_variable) |
