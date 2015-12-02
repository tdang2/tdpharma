class AddManufacturerToMedicine < ActiveRecord::Migration
  def self.up
    add_column :medicines, :manufacturer, :string
  end

  def down
    remove_column :medicines, :manufacturer
  end
end
