class UpdateInventoryItemAttributes < ActiveRecord::Migration
  def change
    add_column :inventory_items, :item_name, :string
    remove_column :inventory_items, :avg_purchase_amount
    remove_column :inventory_items, :avg_purchase_price
    remove_column :inventory_items, :avg_sale_amount
    remove_column :inventory_items, :avg_sale_price
  end
end
