class AddBarcodeToReceipt < ActiveRecord::Migration
  def self.up
    add_column :receipts, :barcode, :string
  end

  def self.down
    remove_column :receipts, :barcode
  end
end
