module ApplicationHelper
  def headline(&block)
    "<h1>#{capture(&block)}</h1>".html_safe
  end
end
