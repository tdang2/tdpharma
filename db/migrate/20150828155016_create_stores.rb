class CreateStores < ActiveRecord::Migration
  def up
    create_table :stores do |t|
      t.string :name
      t.string :phone
      t.belongs_to :company, index: true
      t.timestamps null: false
    end
    add_belongs_to :users, :store, index: true
  end

  def down
    remove_index :users, :store_id
    remove_belongs_to :users, :store
    drop_table :stores
  end
end
