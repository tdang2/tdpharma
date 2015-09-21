class CreateTransactions < ActiveRecord::Migration
  def up
    create_table :transactions do |t|
      t.integer :amount
      t.datetime :delivery_time
      t.datetime :due_date
      t.boolean :paid, default: false
      t.boolean :performed
      t.integer :sale_user_id, index: true
      t.integer :purchase_user_id
      t.integer :buyer_id
      t.integer :seller_id, index: true
      t.integer :buyer_item_id
      t.integer :seller_item_id, index: true
      t.timestamps null: false
    end

  end

  def down
    drop_table :transactions
  end
end
