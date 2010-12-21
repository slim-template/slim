class ParentsAndChildren < ActiveRecord::Migration
  def self.up
    create_table :parents do |t|
      t.string :name
    end
    create_table :children do |t|
      t.string  :name
      t.integer :parent_id
    end
    add_index :children, :parent_id
  end

  def self.down
    drop_table :children
    drop_table :parents
  end
end
