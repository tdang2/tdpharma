class AddBatchInfoToTransaction < ActiveRecord::Migration
  def self.up
    add_belongs_to :med_batches, :receipt, index: true
    add_column :med_batches, :paid, :boolean, default: true
    add_belongs_to :transactions, :med_batch, index: true
  end

  def self.down
    remove_belongs_to :med_batches, :receipt
    remove_belongs_to :transactions, :med_batch
    remove_column :med_batches, :paid
  end
end
