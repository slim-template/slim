require 'rubygems'
require 'rails'
require 'action_controller'
require 'action_view'
require 'slim/rails'
require 'minitest/unit'

MiniTest::Unit.autorun

class TestApp < Rails::Application
  config.root = File.join(File.dirname(__FILE__), 'rails_app')
end
Rails.application = TestApp

class TestSlimRails < MiniTest::Unit::TestCase
  def render(source, &block)
    view                     = ActionView::Base.new
    view.view_paths          = Rails.root.join('views')
    view.controller          = ActionController::Base.new
    view.controller.response = ActionController::Response.new if defined?(ActionController::Response)

    view.render :inline => source, :type => :slim
  end

  def assert_html(expected, source, &block)
    assert_equal expected, render(source, &block)
  end

  def test_rails_template
    source = %q{
html
  head
    title Simple Test Title
  body
    p Hello World, meet Slim.
}

    assert_html '<html><head><title>Simple Test Title</title></head><body><p>Hello World, meet Slim.</p></body></html>', source
  end

  def test_content_for_without_output
    source = %q{
= content_for :content do
  - if false
    .content_one
  - else
    .content_two
}

    assert_html '', source
  end

  def test_content_for_with_output
    source = %q{
= content_for :content do
  - if false
    .content_one
  - else
    .content_two
p This is the captured content
== content_for :content
}

    assert_html '<p>This is the captured content</p><div class="content_two"></div>', source
  end

  def test_content_for_with_output2
    source = %q{
- if true
  = content_for :content do
    p a1
    p a2
- else
  = content_for :content do
    p b1
    p b2
p This is the captured content
== content_for :content
}

    assert_html '<p>This is the captured content</p><p>a1</p><p>a2</p>', source
  end

  def test_content_tag
    source = %q{
= content_tag(:div) do
  p Do not escape this!
}

    assert_html '<div><p>Do not escape this!</p></div>', source
  end

  def test_render_partial
    source = %q{
= render "tests/dummy"
}

    assert_html '<div id="dummy"><p>Dummy data.<p></div>', source
  end
end
