class CreateReceipts < ActiveRecord::Migration
  def up
    create_table :receipts do |t|
      t.float :total
      t.integer :receipt_type
      t.belongs_to :store, index: true
      t.belongs_to :inventory_item, index: true
      t.timestamps null: false
    end

    add_belongs_to :transactions, :receipt, index: true
  end


  def down
    remove_belongs_to :transactions, :receipt
    drop_table :receipts
  end
end
