class AddLastCheckedInToUser < ActiveRecord::Migration
  def change
    add_column :users, :last_checked_in, :datetime
  end
end
