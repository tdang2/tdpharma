class AddTransactionTypeToTransaction < ActiveRecord::Migration
  def up
    add_column :transactions, :transaction_type, :integer
    add_column :transactions, :adjust_item_id, :integer, index: true
    add_column :transactions, :adjust_user_id, :integer, index: true
    add_column :transactions, :adjust_store_id, :integer, index: true
  end

  def down
    remove_column :transactions, :transaction_type
    remove_column :transactions, :adjust_item_id
    remove_column :transactions, :adjust_user_id
    remove_column :transactions, :adjust_store_id
  end
end
