class RecreateGames < ActiveRecord::Migration
  class CreateGames < ActiveRecord::Migration
    def change
      create_table :games do |t|
        t.string :game
        t.float :score
        t.string :description
        t.string :image
        t.integer :review_count
        t.string :tags

        t.timestamps null: false
      end
    end
  end

end
