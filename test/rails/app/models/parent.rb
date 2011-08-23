class Parent < ActiveRecord::Base
  has_many :children
  accepts_nested_attributes_for :children, :allow_destroy => true
end
