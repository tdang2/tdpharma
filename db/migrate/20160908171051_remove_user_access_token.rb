class RemoveUserAccessToken < ActiveRecord::Migration
  def change
    remove_column :users, :authentication_token
  end
end
