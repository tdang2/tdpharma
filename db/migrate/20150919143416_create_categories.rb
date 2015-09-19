class CreateCategories < ActiveRecord::Migration
  def up
    create_table :categories do |t|
      t.string :name
      t.integer :parent_id, :null => true, :index => true
      t.integer :lft, :null => true, :index => true
      t.integer :rgt, :null => true, :index => true
      t.integer :depth, :null => true, :default => 0
      t.integer :children_count, :null => true, :default => 0
      t.timestamps null: false
    end

    add_column :inventory_items, :category_id, :integer, index: true

    create_table :categories_stores, id: false do |t|
      t.belongs_to :store, index: true
      t.belongs_to :category, index: true
      t.integer :discount
    end
  end

  def down
    remove_column :inventory_items, :category_id
    drop_table :categories_stores
    drop_table :categories

  end
end
