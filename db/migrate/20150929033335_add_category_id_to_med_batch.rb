class AddCategoryIdToMedBatch < ActiveRecord::Migration
  def up
    add_column :med_batches, :category_id, :integer, index: true
  end

  def down
    remove_column :med_batches, :category_id
  end
end
