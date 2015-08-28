class AddSelfJoinToUser < ActiveRecord::Migration
  def up
    add_reference :users, :manager, index: true
  end

  def down
    remove_index :users, :manager_id
    remove_reference :users, :manager
  end
end
