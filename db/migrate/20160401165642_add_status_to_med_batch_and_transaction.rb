class AddStatusToMedBatchAndTransaction < ActiveRecord::Migration
  def self.up
    add_column :transactions, :status, :integer, default: 0
    add_column :med_batches, :status, :integer, default: 0
  end

  def self.down
    remove_column :transactions, :status
    remove_column :med_batches, :status
  end
end
