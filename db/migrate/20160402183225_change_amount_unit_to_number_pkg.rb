class ChangeAmountUnitToNumberPkg < ActiveRecord::Migration
  def self.up
    remove_column :med_batches, :amount_unit
    add_column :med_batches, :number_pkg, :integer
  end

  def self.down
    remove_column :med_batches, :number_pkg
    add_column :med_batches, :amount_unit, :integer
  end
end
