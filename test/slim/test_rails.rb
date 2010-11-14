require 'helper'

require 'rubygems'
require 'rails'
require 'action_controller'
require 'action_view'
require 'slim/rails'

class TestSlimRails < TestSlim
  def render(source, &block)
    view = ActionView::Base.new
    view.controller = ActionController::Base.new
    if defined?(ActionController::Response)
      # This is needed for >=3.0.0
      view.controller.response = ActionController::Response.new
    end
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
end
