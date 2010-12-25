require 'tilt'

class ComplexView
  def header
    "Colors"
  end

  def item
    items = []
    items << { :name => 'red', :current => true, :url => '#red' }
    items << { :name => 'green', :current => false, :url => '#green' }
    items << { :name => 'blue', :current => false, :url => '#blue' }
    items
  end
end
