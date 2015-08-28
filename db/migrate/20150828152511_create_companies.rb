class CreateCompanies < ActiveRecord::Migration
  def up
    create_table :companies do |t|
      t.string :name
      t.string :phone
      t.text   :description
      t.string :email
      t.string :website
      t.timestamps null: false
    end
  end


  def down
    drop_table :companies
  end
end
