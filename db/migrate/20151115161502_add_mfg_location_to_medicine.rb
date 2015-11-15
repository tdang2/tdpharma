class AddMfgLocationToMedicine < ActiveRecord::Migration
  def change
    add_column :medicines, :mfg_location, :string
    remove_column :med_batches, :mfg_location
    add_column :users, :preferred_language, :integer
  end
end
