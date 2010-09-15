require 'helper'

class TestEngine
  include Slim::Precompiler

  def initialize(template)
    @template = template
    precompile
  end

  def precompiled
    @precompiled
  end
end

class TestSlimEngine < MiniTest::Unit::TestCase

  def test_simple_html
    string = <<HTML
html
  head
    title Simple Test Title
  body
    p Hello World, meet Slim.
HTML

    expected = %q|_buf = [];_buf << "<html>";_buf << "<head>";_buf << "<title>";_buf << "Simple Test Title";_buf << "</title>";_buf << "</head>";_buf << "<body>";_buf << "<p>";_buf << "Hello World, meet Slim.";_buf << "</p>";_buf << "</body>";_buf << "</html>";_buf.join;|

    output = TestEngine.new(string).precompiled

    assert_equal expected, output
  end

  def test_simple_html_with_doctype
    string = <<HTML
! doctype html5
html
  head
    title Simple Test Title
  body
    p Hello World, meet Slim.
HTML

    expected = %q|_buf = [];_buf << "<! doctype html5 >";_buf << "<html>";_buf << "<head>";_buf << "<title>";_buf << "Simple Test Title";_buf << "</title>";_buf << "</head>";_buf << "<body>";_buf << "<p>";_buf << "Hello World, meet Slim.";_buf << "</p>";_buf << "</body>";_buf << "</html>";_buf.join;|

    output = TestEngine.new(string).precompiled

    assert_equal expected, output
  end


  def test_simple_html_with_params
    string = <<HTML
html 
  head
    title Simple Test Title
    meta name="description" content="This is a Slim Test, that's all"
  body
    p Hello World, meet Slim.
HTML

    expected = %q|_buf = [];_buf << "<html>";_buf << "<head>";_buf << "<title>";_buf << "Simple Test Title";_buf << "</title>";_buf << "<meta name=\"description\" content=\"This is a Slim Test, that's all\"/>";_buf << "</head>";_buf << "<body>";_buf << "<p>";_buf << "Hello World, meet Slim.";_buf << "</p>";_buf << "</body>";_buf << "</html>";_buf.join;|

    output = TestEngine.new(string).precompiled

    assert_equal expected, output
  end

  def test_simple_html_with_params_meta_first
    string = <<HTML
html 
  head
    meta name="description" content="This is a Slim Test, that's all"
    title Simple Test Title
  body
    p Hello World, meet Slim.
HTML

    expected = %q|_buf = [];_buf << "<html>";_buf << "<head>";_buf << "<meta name=\"description\" content=\"This is a Slim Test, that's all\"/>";_buf << "<title>";_buf << "Simple Test Title";_buf << "</title>";_buf << "</head>";_buf << "<body>";_buf << "<p>";_buf << "Hello World, meet Slim.";_buf << "</p>";_buf << "</body>";_buf << "</html>";_buf.join;|

    output = TestEngine.new(string).precompiled

    assert_equal expected, output
  end

  def test_nested_content
    string = <<HTML
html 
  head
    meta name="description" content="This is a Slim Test, that's all"
    title Simple Test Title
  body
    p 
      ` Hello World, meet Slim.
HTML

    expected = %q|_buf = [];_buf << "<html>";_buf << "<head>";_buf << "<meta name=\"description\" content=\"This is a Slim Test, that's all\"/>";_buf << "<title>";_buf << "Simple Test Title";_buf << "</title>";_buf << "</head>";_buf << "<body>";_buf << "<p>";_buf << "Hello World, meet Slim.";_buf << "</p>";_buf << "</body>";_buf << "</html>";_buf.join;|

    output = TestEngine.new(string).precompiled

    assert_equal expected, output
  end

  def test_closing_tag_without_content_or_attributes
    string = <<HTML
html 
  head
    meta name="description" content="This is a Slim Test, that's all"
    title Simple Test Title
  body
    hr
    p 
      ` Hello World, meet Slim.
HTML

    expected = %q|_buf = [];_buf << "<html>";_buf << "<head>";_buf << "<meta name=\"description\" content=\"This is a Slim Test, that's all\"/>";_buf << "<title>";_buf << "Simple Test Title";_buf << "</title>";_buf << "</head>";_buf << "<body>";_buf << "<hr/>";_buf << "<p>";_buf << "Hello World, meet Slim.";_buf << "</p>";_buf << "</body>";_buf << "</html>";_buf.join;|

    output = TestEngine.new(string).precompiled

    assert_equal expected, output
  end


  def test_closing_tag_without_content
    string = <<HTML
html 
  head
    meta name="description" content="This is a Slim Test, that's all"
    title Simple Test Title
  body
    img width="100" height="50" src="/images/test.jpg"
    p 
      ` Hello World, meet Slim.
HTML

    expected = %q|_buf = [];_buf << "<html>";_buf << "<head>";_buf << "<meta name=\"description\" content=\"This is a Slim Test, that's all\"/>";_buf << "<title>";_buf << "Simple Test Title";_buf << "</title>";_buf << "</head>";_buf << "<body>";_buf << "<img width=\"100\" height=\"50\" src=\"/images/test.jpg\"/>";_buf << "<p>";_buf << "Hello World, meet Slim.";_buf << "</p>";_buf << "</body>";_buf << "</html>";_buf.join;|

    output = TestEngine.new(string).precompiled

    assert_equal expected, output
  end


  def test_text_that_starts_with_tag_name
    string = <<HTML
html
  head
    meta name="description" content="This is a Slim Test, that's all"
    title Simple Test Title
  body
    img width="100" height="50" src="/images/test.jpg"
    p 
      ` another one bites the dust
    p
      ` i am iron man
HTML

    expected = %q|_buf = [];_buf << "<html>";_buf << "<head>";_buf << "<meta name=\"description\" content=\"This is a Slim Test, that's all\"/>";_buf << "<title>";_buf << "Simple Test Title";_buf << "</title>";_buf << "</head>";_buf << "<body>";_buf << "<img width=\"100\" height=\"50\" src=\"/images/test.jpg\"/>";_buf << "<p>";_buf << "another one bites the dust";_buf << "</p>";_buf << "<p>";_buf << "i am iron man";_buf << "</p>";_buf << "</body>";_buf << "</html>";_buf.join;|

    output = TestEngine.new(string).precompiled

    assert_equal expected, output
  end


  def test_simple_if_code_block
    string = <<HTML
html
  head
    meta name="description" content="This is a Slim Test, that's all"
    title Simple Test Title
  body
    - if something
      p 
        ` another one bites the dust
    - else
      p
        ` i am iron man
HTML

expected = %q|_buf = [];_buf << "<html>";_buf << "<head>";_buf << "<meta name=\"description\" content=\"This is a Slim Test, that's all\"/>";_buf << "<title>";_buf << "Simple Test Title";_buf << "</title>";_buf << "</head>";_buf << "<body>";if something;_buf << "<p>";_buf << "another one bites the dust";_buf << "</p>";else;_buf << "<p>";_buf << "i am iron man";_buf << "</p>";end;_buf << "</body>";_buf << "</html>";_buf.join;|

    output = TestEngine.new(string).precompiled

    assert_equal expected, output
  end

  # Use this to do a line by line check. Much easier to see where the problem is.
  def iterate_it(expected, output)
    es = expected.split(';')
    output.split(';').each_with_index do |text, index|
      assert_equal(text, es[index])
    end
  end

  def test_simple_output_code
    string = <<HTML
html
  head
    title Simple Test Title
  body
    p 
      = hello_world
HTML

    expected = %q|_buf = [];_buf << "<html>";_buf << "<head>";_buf << "<title>";_buf << "Simple Test Title";_buf << "</title>";_buf << "</head>";_buf << "<body>";_buf << "<p>";_buf << hello_world;_buf << "</p>";_buf << "</body>";_buf << "</html>";_buf.join;|

    output = TestEngine.new(string).precompiled

    assert_equal expected, output
  end

  def test_simple_output_code_with_params
    string = <<HTML
html
  head
    title Simple Test Title
  body
    p 
      = hello_world(params[:key])
HTML

    expected = %q|_buf = [];_buf << "<html>";_buf << "<head>";_buf << "<title>";_buf << "Simple Test Title";_buf << "</title>";_buf << "</head>";_buf << "<body>";_buf << "<p>";_buf << hello_world(params[:key]);_buf << "</p>";_buf << "</body>";_buf << "</html>";_buf.join;|

    output = TestEngine.new(string).precompiled

    assert_equal expected, output
  end


end
