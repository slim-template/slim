require 'helper'

class TestSlimPretty < TestSlim
  def setup
    Slim::Engine.set_default_options :pretty => true
  end

  def teardown
    Slim::Engine.set_default_options :pretty => false
  end

  def test_pretty
    source = %q{
doctype 5
html
  head
    title Hello World!
    sass:
      body
        background-color: red
  body
    #container
      p Hello
        World!
      p= "dynamic text with\nnewline"
}

    result = %q{<!DOCTYPE html>
<html>
  <head>
    <title>Hello World!</title>
    <style type="text/css">
      body {
        background-color: red;
      } 
    </style>
  </head>
  <body>
    <div id="container">
      <p>Hello
        World!</p>
      <p>dynamic text with
        newline</p>
    </div>
  </body>
</html>}

    assert_html result, source
  end
end
