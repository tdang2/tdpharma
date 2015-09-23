class AddItemableToInventoryItem < ActiveRecord::Migration
  def up
    add_column :inventory_items, :itemable_id, :integer, index: true
    add_column :inventory_items, :itemable_type, :string

    drop_table :inventory_items_med_batches

    add_column :med_batches, :inventory_item_id, :integer, index: true
    add_column :med_batches, :store_id, :integer, index: true
    add_column :med_batches, :total_units, :integer
    add_column :med_batches, :user_id, :integer, index: true
    add_column :med_batches, :price, :float
  end

  def down
    create_table :inventory_items_med_batches, id: false do |t|
      t.belongs_to :med_batch, index: true
      t.belongs_to :inventory_item, index: true
    end
    remove_column :med_batches, :store_id
    remove_column :med_batches, :inventory_item_id
    remove_column :med_batches, :total_units
    remove_column :med_batches, :user_id
    remove_column :med_batches, :price
    remove_column :inventory_items, :itemable_type
    remove_column :inventory_items, :itemable_id
  end
end
