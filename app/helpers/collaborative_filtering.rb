require 'json'
require 'pry'

def get_users_mean(ratings_array)
  mean_ratings = Hash.new
  ratings_array.each do |i|
    user = i["user"]

    sum = 0
    keys = i.keys
    keys.each do |key|
      rating = i[key].to_i
      sum += rating
    end

    mean = sum / (keys.size.to_f - 1)
    mean_ratings.store(user, mean)
  end

  file = File.open("../../user_means", "w")
  file << mean_ratings.to_json
  file.close

  return mean_ratings
end

def similarity_between(f_user, s_user, mean_ratings)
  f_mean = mean_ratings[f_user["user"]]
  s_mean = mean_ratings[s_user["user"]]
  x = 0
  y = 0
  upper_sum = 0
  f_lower_sum = 0
  s_lower_sum = 0
  co_rated = 0

  #puts "f_mean = #{f_mean}"
  #puts "s_mean = #{s_mean}"

  f_user.each do |f_key, f_value|
    s_user.each do |s_key, s_value|
      if f_key == s_key && f_key != "user"
        x = f_value.to_f - f_mean
        y = s_value.to_f - s_mean

        #puts "f_value = #{f_value}"
        #puts "s_value = #{s_value}"

        #puts "x = #{x}"
        #puts "y = #{y}"

        upper_sum += x * y
        f_lower_sum += x ** 2
        s_lower_sum += y ** 2

        #puts "upper_sum = #{upper_sum}"
        #puts "f_lower_sum = #{f_lower_sum}"
        #puts "s_lower_sum = #{s_lower_sum}"

        co_rated += 1
      end
    end
  end

  sim = upper_sum / (Math.sqrt((f_lower_sum)) * Math.sqrt((s_lower_sum)))
  return sim.nan? ? 0 : sim * ([co_rated, 50].min / 50.to_f)
end

def compute_similarities(ratings_array, mean_ratings)
  pocet = 0
  pair = Array.new
  similarities_hash = Hash.new
  i = 0
  j = 0
  until i > ratings_array.size - 1
    j = i + 1
    until j > ratings_array.size - 1
      pair = [ratings_array[i]["user"], ratings_array[j]["user"]]
      sim = similarity_between(ratings_array[i], ratings_array[j], mean_ratings)

      #p pocet if pocet % 10 == 0
      pocet=pocet+1
      if !sim.to_f.nan?
        similarities_hash.store(pair, sim)
      end
      j += 1
    end
    i += 1
  end
  return similarities_hash.sort_by { |key, value| value }.reverse
end

def user_standard_deviation(user, mean)
  sum = 0
  #puts "mean = #{mean}"

  user.each do |key, value|
    if key != "user"
      #puts "value = #{value}"
      sum += (value.to_f - mean) ** 2
    end
  end
  var = sum / (user.size - 1)
  return Math.sqrt(var)
end

def get_z_score(rating, user, mean)
  s_dev = user_standard_deviation(user, mean)
  return s_dev == 0 ? 0 : (rating.to_f - mean) / s_dev
end

def prediction_for_item(item, user_a, ratings_array, mean_ratings)
  upper_sum = 0
  lower_sum = 0
  username_a = user_a["user"]
  mean = mean_ratings[username_a]
  s_dev = user_standard_deviation(user_a, mean)

  ratings_array.each do |user_b|
    next if user_b == user_a

    item_rating = user_b[item]
    next if item_rating.nil?

    z_score = get_z_score(item_rating, user_b, mean)
    sim = similarity_between(user_a, user_b, mean_ratings)
    upper_sum += z_score * sim
    lower_sum += sim

  end
  return lower_sum == 0 ? 0 : upper_sum / lower_sum * s_dev + mean
end

def get_most_similar_users(user_str, similarity_hash)
  count = 0
  most_similar = Hash.new

  similarity_hash.each do |key, value|
    if key.include? user_str
      most_similar.store(key[1], value)
      count += 1
    end

    break if count == 50
  end
  return most_similar
end

def find_user(username, ratings_array)
  ratings_array.each do |x|
    return x if x["user"] == username
  end
end

def get_most_common_items(user_a, most_similar_users, ratings_array)
  most_common_items = Hash.new
  most_similar_users.each do |key, value|
    user_b = find_user(key, ratings_array)

    user_b.each do |key, value|
      next if key == "user"
      next if user_a[key].nil?

      item_count = most_common_items[key]
      item_count = 0 if item_count.nil?
      item_count += 1

      most_common_items.store(key, item_count)
    end
  end

  return most_common_items.sort_by { |key, value| value }.reverse.first(50)
end

def predictions_for_user(most_common_items, user, ratings_array, mean_ratings)
  predictions = Hash.new
  most_common_items.each do |key, value|
    pred = prediction_for_item(key, user, ratings_array, mean_ratings)
    #p "game = #{key}, pred = #{pred}"
    next if pred.to_f.nan?
    predictions.store(key, pred)
  end
  return predictions.sort_by { |x, y| y }.reverse
end

def get_ratings_array()
  file = open("../../GOOD")
  json = file.read
  file.close
  return JSON.parse(json)
end

def compute_predictions()
  ratings_array = get_ratings_array()
  mean_ratings = get_users_mean(ratings_array)
  similarity_hash = compute_similarities(ratings_array, mean_ratings)

  predictions_all = Hash.new
  ratings_array.each do |user|
    username = user["user"]
    most_similar_users = get_most_similar_users(username, similarity_hash)
    most_common_items = get_most_common_items(user, most_similar_users, ratings_array)
    predictions = predictions_for_user(most_common_items, user, ratings_array, mean_ratings)
    predictions_all.store(username, predictions)
  end

  file = File.open("../../predictions_cf", "w")
  file.write(predictions_all.to_json)
  file.close
end

class CollaborativeFiltering
  binding.pry
  compute_predictions
end