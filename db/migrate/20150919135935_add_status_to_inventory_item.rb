class AddStatusToInventoryItem < ActiveRecord::Migration
  def up
    add_column :inventory_items, :status, :integer, default: 0
  end

  def down
    remove_column :inventory_items, :status
  end
end
