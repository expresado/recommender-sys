require 'json'
require 'pry'
require './collaborative_filtering'

def extract_ratings(ratings_array)
  ratings = Array.new;
  ratings_array.each do |user|
    user.each do |key, value|
      next if key == "user"
      ratings.push(value)
    end
  end
  return ratings
end

def normalized_ratings(ratings_array, users_mean)
  user = String.new
  normalized_ratings = Array.new

  ratings_array.each do |user|
    user_name = user["user"]

    user.each do |key, value|
      next if key == "user"
      z_score = get_z_score(value, user, users_mean[user_name])
      normalized_ratings.push(z_score)
    end
  end
  return normalized_ratings
end

class DataHelper
  file = open("../../GOOD")
  json = file.read
  ratings_array = JSON.parse(json)

  ratings = extract_ratings(ratings_array)
  users_mean = get_users_mean(ratings_array)
  normalized_ratings = normalized_ratings(ratings_array, users_mean)

  file = File.open("../../data_before_normalization", "w")
  file.write(ratings)

  file = File.open("../../data_after_normalization", "w")
  file.write(normalized_ratings)
end