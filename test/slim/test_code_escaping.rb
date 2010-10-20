require 'helper'

class TestSlimCodeEscaping < TestSlim
  def test_escaping_evil_method
    string = <<HTML
p = evil_method
HTML

    expected = '<p>&lt;script&gt;do_something_evil();&lt;&#47;script&gt;</p>'

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_escape_interpolation
    string = <<HTML
p \\\#{hello_world}
HTML

    expected = '<p>#{hello_world}</p>'

    assert_equal expected, Slim::Engine.new(string).render(@env)
  end

  def test_render_without_html_safe
    string = <<HTML
p = "<strong>Hello World\\n, meet \\"Slim\\"</strong>."
HTML

    expected = "<p>&lt;strong&gt;Hello World\n, meet \&quot;Slim\&quot;&lt;&#47;strong&gt;.</p>"

    assert_equal expected, Slim::Engine.new(string).render
  end

  def test_render_with_html_safe_false
    String.send(:define_method, :html_safe?) { false }

    string = <<HTML
p = "<strong>Hello World\\n, meet \\"Slim\\"</strong>."
HTML

    expected = "<p>&lt;strong&gt;Hello World\n, meet \&quot;Slim\&quot;&lt;&#47;strong&gt;.</p>"

    assert_equal expected, Slim::Engine.new(string, :use_html_safe => true).render
  end

  def test_render_with_html_safe_true
    String.send(:define_method, :html_safe?) { true }

    string = <<HTML
p = "<strong>Hello World\\n, meet \\"Slim\\"</strong>."
HTML

    expected = "<p><strong>Hello World\n, meet \"Slim\"</strong>.</p>"

    assert_equal expected, Slim::Engine.new(string, :use_html_safe => true).render
  end

  def test_render_with_global_html_safe_false
    String.send(:define_method, :html_safe?) { false }
    Slim::Filter::DEFAULT_OPTIONS[:use_html_safe] = false

    string = <<HTML
p = "<strong>Hello World\\n, meet \\"Slim\\"</strong>."
HTML

    expected = "<p>&lt;strong&gt;Hello World\n, meet \&quot;Slim\&quot;&lt;&#47;strong&gt;.</p>"

    assert_equal expected, Slim::Engine.new(string).render
  end

  def test_render_with_global_html_safe_true
    String.send(:define_method, :html_safe?) { true }
    Slim::Filter::DEFAULT_OPTIONS[:use_html_safe] = true

    string = <<HTML
p = "<strong>Hello World\\n, meet \\"Slim\\"</strong>."
HTML

    expected = "<p><strong>Hello World\n, meet \"Slim\"</strong>.</p>"

    assert_equal expected, Slim::Engine.new(string).render
  end
end
