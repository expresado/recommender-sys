class AddColumnsToGames < ActiveRecord::Migration
  def change
    add_column :games, :publisher, :string
    add_column :games, :published, :string
  end
end
