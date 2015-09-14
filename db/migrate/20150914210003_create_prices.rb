class CreatePrices < ActiveRecord::Migration
  def up
    create_table :prices do |t|
      t.integer :amount
      t.integer :discount
      t.string :priceable_type
      t.string :priceable_id, index: true
      t.timestamps null: false
    end
  end

  def down
    drop_table :prices
  end
end
