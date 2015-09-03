class CreateImages < ActiveRecord::Migration
  def up
    create_table :images do |t|
      t.string :imageable_type
      t.integer :imageable_id, index: true
      t.attachment :photo
      t.string :direct_upload_url
      t.boolean :processed
      t.timestamps null: false
    end
  end

  def down
    drop_table :images
  end
end
