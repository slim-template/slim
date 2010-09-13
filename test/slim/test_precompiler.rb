require 'helper'

class TestEngine
  include Slim::Precompiler

  def initialize(template)
    @template = template
    precompile
  end

  def render
    eval(@precompiled)
  end
end

class TestSlimEngine < MiniTest::Unit::TestCase

  def test_simple_html
    string = <<-HTML
    html 
      head
        title Simple Test Title
      body
        p Hello World, meet Slim.
    HTML

    expected = "<html><head><title>Simple Test Title</title></head><body><p>Hello World, meet Slim.</p></body></html>"

    output = TestEngine.new(string).render

    assert_equal expected, output
  end

  def test_simple_html_with_params
    string = <<-HTML
    html 
      head
        title Simple Test Title
        meta name="description" content="This is a Slim Test, that's all"
      body
        p Hello World, meet Slim.
    HTML

    expected = "<html><head><title>Simple Test Title</title><meta name=\"description\" content=\"This is a Slim Test, that's all\"/></head><body><p>Hello World, meet Slim.</p></body></html>"

    output = TestEngine.new(string).render

    assert_equal expected, output
  end

  def test_simple_html_with_params_meta_first
    string = <<-HTML
    html 
      head
        meta name="description" content="This is a Slim Test, that's all"
        title Simple Test Title
      body
        p Hello World, meet Slim.
    HTML

    expected = "<html><head><meta name=\"description\" content=\"This is a Slim Test, that's all\"/><title>Simple Test Title</title></head><body><p>Hello World, meet Slim.</p></body></html>"

    output = TestEngine.new(string).render

    assert_equal expected, output
  end
end
