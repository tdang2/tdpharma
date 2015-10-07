class DeviseTokenAuthCreateUsers < ActiveRecord::Migration
  def change
    add_column :users, :provider, :string, null: false, defaul: 'email'
    add_column :users, :uid, :string, null: false, default: ''
    add_column :users, :tokens, :json
    add_index :users, [:uid, :provider],     :unique => true
    # add_index :users, :reset_password_token, :unique => true
    # add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :unlock_token,         :unique => true
  end
end
