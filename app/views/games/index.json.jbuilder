json.array!(@games) do |game|
  json.extract! game, :id, :game, :score, :description, :image, :review_count
  json.url game_url(game, format: :json)
end
