require 'helper'

class TestSlimEngine < MiniTest::Unit::TestCase

  def setup
    @env = Env.new
  end

  def test_simple_render
    string = <<HTML
html
  head
    title Simple Test Title
  body
    p Hello World, meet Slim.
HTML

    engine = Slim::Engine.new(string)

    expected = "<html><head><title>Simple Test Title</title></head><body><p>Hello World, meet Slim.</p></body></html>"

    assert_equal expected, engine.render
  end

  def test_render_with_conditional
    string = <<HTML
html
  head
    title Simple Test Title
  body
    - if show_first?
        p The first paragraph
    - else
        p The second paragraph
HTML

    engine = Slim::Engine.new(string)

    expected = "<html><head><title>Simple Test Title</title></head><body><p>The second paragraph</p></body></html>"

    assert_equal expected, engine.render(@env)
  end

  def test_render_with_call
    string = <<HTML
html
  head
    title Simple Test Title
  body
    p
      = hello_world
HTML

    engine = Slim::Engine.new(string)

    expected = "<html><head><title>Simple Test Title</title></head><body><p>Hello World from @env</p></body></html>"

    assert_equal expected, engine.render(@env)
  end

  def test_render_with_call_and_inline_text
    string = <<HTML
html
  head
    title Simple Test Title
  body
    h1 This is my title
    p
      = hello_world
HTML

    engine = Slim::Engine.new(string)

    expected = "<html><head><title>Simple Test Title</title></head><body><h1>This is my title</h1><p>Hello World from @env</p></body></html>"

    assert_equal expected, engine.render(@env)
  end

  def test_render_with_call_to_set_attribute
    string = <<HTML
html
  head
    title Simple Test Title
  body
    h1 This is my title
    p id="#\{id_helper}"
      = hello_world
HTML

    engine = Slim::Engine.new(string)

    expected = "<html><head><title>Simple Test Title</title></head><body><h1>This is my title</h1><p id=\"notice\">Hello World from @env</p></body></html>"

    assert_equal expected, engine.render(@env)
  end

  def test_render_with_call_to_set_attribute_and_call_to_set_content
    string = <<HTML
html
  head
    title Simple Test Title
  body
    h1 This is my title
    p id="#\{id_helper}" = hello_world
HTML

    engine = Slim::Engine.new(string)

    expected = "<html><head><title>Simple Test Title</title></head><body><h1>This is my title</h1><p id=\"notice\">Hello World from @env</p></body></html>"

    assert_equal expected, engine.render(@env)
  end

  def test_render_with_text_block
    string = <<HTML
html
  head
    title Simple Test Title
  body
    h1 This is my title
    p id="#\{id_helper}"
      `
        Phasellus ultricies vulputate lacus, eget pretium orci tincidunt tristique. Duis vitae luctus risus. Aliquam turpis massa, adipiscing in adipiscing ut, congue sed justo. Sed egestas ullamcorper nisl placerat dictum. Sed a leo lectus, sit amet vehicula nisl. Duis adipiscing congue tortor ut vulputate. Phasellus ligula lectus, congue non lobortis sed, dictum sed tellus. Vestibulum viverra vestibulum felis convallis pharetra. Phasellus a dignissim tellus. Proin dapibus malesuada lorem, et porttitor diam bibendum a. Donec et dui mauris, et tempus metus. Etiam pharetra varius dignissim. Maecenas lacinia, ligula ut tincidunt porttitor, sapien nisi pulvinar magna, nec sollicitudin libero odio bibendum nisi. Aenean ipsum eros, convallis id consequat nec, commodo eget diam. Integer malesuada, libero non dignissim varius, velit metus malesuada lectus, a consequat turpis purus ut elit.
HTML

    engine = Slim::Engine.new(string)

    expected = "<html><head><title>Simple Test Title</title></head><body><h1>This is my title</h1><p id=\"notice\">  Phasellus ultricies vulputate lacus, eget pretium orci tincidunt tristique. Duis vitae luctus risus. Aliquam turpis massa, adipiscing in adipiscing ut, congue sed justo. Sed egestas ullamcorper nisl placerat dictum. Sed a leo lectus, sit amet vehicula nisl. Duis adipiscing congue tortor ut vulputate. Phasellus ligula lectus, congue non lobortis sed, dictum sed tellus. Vestibulum viverra vestibulum felis convallis pharetra. Phasellus a dignissim tellus. Proin dapibus malesuada lorem, et porttitor diam bibendum a. Donec et dui mauris, et tempus metus. Etiam pharetra varius dignissim. Maecenas lacinia, ligula ut tincidunt porttitor, sapien nisi pulvinar magna, nec sollicitudin libero odio bibendum nisi. Aenean ipsum eros, convallis id consequat nec, commodo eget diam. Integer malesuada, libero non dignissim varius, velit metus malesuada lectus, a consequat turpis purus ut elit.</p></body></html>"

    assert_equal expected, engine.render(@env)
  end


  def test_render_with_text_block_with_subsequent_markup
    string = <<HTML
html
  head
    title Simple Test Title
  body
    h1 This is my title
    p id="#\{id_helper}"
      `
        Phasellus ultricies vulputate lacus, eget pretium orci tincidunt tristique. Duis vitae luctus risus. Aliquam turpis massa, adipiscing in adipiscing ut, congue sed justo. Sed egestas ullamcorper nisl placerat dictum. Sed a leo lectus, sit amet vehicula nisl. Duis adipiscing congue tortor ut vulputate. Phasellus ligula lectus, congue non lobortis sed, dictum sed tellus. Vestibulum viverra vestibulum felis convallis pharetra. Phasellus a dignissim tellus. Proin dapibus malesuada lorem, et porttitor diam bibendum a. Donec et dui mauris, et tempus metus. Etiam pharetra varius dignissim. Maecenas lacinia, ligula ut tincidunt porttitor, sapien nisi pulvinar magna, nec sollicitudin libero odio bibendum nisi. Aenean ipsum eros, convallis id consequat nec, commodo eget diam. Integer malesuada, libero non dignissim varius, velit metus malesuada lectus, a consequat turpis purus ut elit.
    p Some more markup
HTML

    engine = Slim::Engine.new(string)

    expected = "<html><head><title>Simple Test Title</title></head><body><h1>This is my title</h1><p id=\"notice\">  Phasellus ultricies vulputate lacus, eget pretium orci tincidunt tristique. Duis vitae luctus risus. Aliquam turpis massa, adipiscing in adipiscing ut, congue sed justo. Sed egestas ullamcorper nisl placerat dictum. Sed a leo lectus, sit amet vehicula nisl. Duis adipiscing congue tortor ut vulputate. Phasellus ligula lectus, congue non lobortis sed, dictum sed tellus. Vestibulum viverra vestibulum felis convallis pharetra. Phasellus a dignissim tellus. Proin dapibus malesuada lorem, et porttitor diam bibendum a. Donec et dui mauris, et tempus metus. Etiam pharetra varius dignissim. Maecenas lacinia, ligula ut tincidunt porttitor, sapien nisi pulvinar magna, nec sollicitudin libero odio bibendum nisi. Aenean ipsum eros, convallis id consequat nec, commodo eget diam. Integer malesuada, libero non dignissim varius, velit metus malesuada lectus, a consequat turpis purus ut elit.</p><p>Some more markup</p></body></html>"

    assert_equal expected, engine.render(@env)
  end


end
