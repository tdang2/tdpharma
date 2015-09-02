class CreateLocations < ActiveRecord::Migration
  def up
    create_table :locations do |t|
      t.string :name
      t.string :address
      t.string :locationable_type
      t.integer :locationable_id, index: true
      t.float :longitude
      t.float :latitude
      t.timestamps null: false
    end
  end

  def down
    drop_table :locations
  end
end
