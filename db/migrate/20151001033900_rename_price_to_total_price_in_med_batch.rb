class RenamePriceToTotalPriceInMedBatch < ActiveRecord::Migration
  def up
    rename_column :med_batches, :price, :total_price
    add_column :transactions, :total_price, :float
  end

  def down
    rename_column :med_batches, :total_price, :price
    remove_column :transactions, :total_price
  end
end
