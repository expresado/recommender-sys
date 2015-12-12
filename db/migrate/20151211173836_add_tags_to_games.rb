class AddTagsToGames < ActiveRecord::Migration
  def change
    add_column :games, :tags, :string
  end
end
