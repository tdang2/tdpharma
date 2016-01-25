class AddBarcodeAndTotalNewInformation < ActiveRecord::Migration
  def self.up
    add_column :med_batches, :barcode, :string
    add_column :transactions, :new_total, :integer
  end


  def self.down
    remove_column :med_batches, :barcode
    remove_column :transactions, :new_total
  end
end
