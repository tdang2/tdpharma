class ChangeTransactionAssociation < ActiveRecord::Migration
  def change
    remove_column :transactions, :buyer_id
    remove_column :transactions, :seller_id
    remove_column :transactions, :adjust_store_id

    remove_column :transactions, :buyer_item_id
    remove_column :transactions, :seller_item_id
    remove_column :transactions, :adjust_item_id

    remove_column :transactions, :purchase_user_id
    remove_column :transactions, :sale_user_id
    remove_column :transactions, :adjust_user_id

    add_column :transactions, :store_id, :integer, index: :true
    add_column :transactions, :user_id, :integer, index: :true
    add_column :transactions, :inventory_item_id, :integer, index: :true
  end
end
