class SlimController < ApplicationController
  def normal
  end

  def xml
  end

  def no_layout
    render layout: false
  end

  def variables
    @hello = "Hello Slim with variables!"
  end

  def partial
  end

  def streaming
    @hello = "Hello Streaming!"
    render :content_for, stream: true
  end

  def integers
    @integer = 1337
  end

  def thread_options
    Slim::Engine.with_options(shortcut: {'@' => { attr: params[:attr] }}) do
      render
    end
  end

  def content_for
    @hello = "Hello Slim!"
  end

  def helper
  end
end
