class AddUserToJsoned < ActiveRecord::Migration
  def change
  	add_column :users, :user_data, :jsonb
  end
end
