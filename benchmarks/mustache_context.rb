require 'mustache'

class MustacheContext < Mustache
  self.template_file = './view.mustache'

  def header
    'Colors'
  end

  def item_present?
    !item.empty?
  end

  def item
    [ { :name => 'red',   :current => true,  :url => '#red'   },
      { :name => 'green', :current => false, :url => '#green' },
      { :name => 'blue',  :current => false, :url => '#blue'  } ]
  end
end
