class CreateInventoryItems < ActiveRecord::Migration
  def up
    create_table :inventory_items do |t|
      t.integer :amount, default: 0
      t.float :avg_purchase_price
      t.float :avg_sale_price
      t.float :avg_purchase_amount
      t.float :avg_sale_amount
      t.timestamps null: false
    end

    create_table :inventory_items_medicines, id: false do |t|
      t.belongs_to :medicine, index: true
      t.belongs_to :inventory_item, index: true
    end
  end

  def down
    drop_table :inventory_items_medicines
    drop_table :inventory_items
  end
end
