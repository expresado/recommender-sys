class TestJsonTable < ActiveRecord::Migration
  def change
  	  create_table :jsoned do |t|
	  t.jsonb :data
	end
  end
end
