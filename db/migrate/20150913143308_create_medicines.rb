class CreateMedicines < ActiveRecord::Migration
  def up
    create_table :medicines do |t|
      t.string :name
      t.integer :concentration
      t.string :concentration_unit
      t.string :med_form
      t.timestamps null: false
    end
  end

  def down
    drop_table :medicines
  end
end
