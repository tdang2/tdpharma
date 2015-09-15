class CreateMedBatches < ActiveRecord::Migration
  def up
    create_table :med_batches do |t|
      t.date :mfg_date
      t.date :expire_date
      t.string :package
      t.string :mfg_location
      t.integer :amount_per_pkg
      t.string :amount_unit
      t.belongs_to :medicine, index: true
      t.timestamps null: false
    end

    create_table :inventory_items_med_batches, id: false do |t|
      t.belongs_to :med_batch, index: true
      t.belongs_to :inventory_item, index: true
    end

    add_column :inventory_items, :store_id, :integer, index: true
    add_column :stores, :inventory_items_count, :integer

    drop_table :inventory_items_medicines
  end

  def down
    create_table :inventory_items_medicines, id: false do |t|
      t.belongs_to :medicine, index: true
      t.belongs_to :inventory_item, index: true
    end
    remove_column :inventory_items, :store_id
    remove_column :stores, :inventory_items_count
    drop_table :med_batches
    drop_table :inventory_items_med_batches
  end
end
