class RemoveInventoryItemIdFromReceipt < ActiveRecord::Migration
  def up
    remove_index :receipts, :inventory_item_id
    remove_column :receipts, :inventory_item_id
  end

  def down
    add_belongs_to :receipts, :inventory_item, index: true
  end
end
