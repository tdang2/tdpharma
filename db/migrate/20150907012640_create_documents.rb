class CreateDocuments < ActiveRecord::Migration
  def up
    create_table :documents do |t|
      t.string :documentable_type
      t.integer :documentable_id, index: true
      t.attachment :doc
      t.string :direct_upload_url
      t.boolean :processed
      t.timestamps null: false
    end
  end

  def down
    drop_table :documents
  end
end
