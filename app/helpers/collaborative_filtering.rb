require 'json'

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
        x = f_value.to_i - f_mean
        y = s_value.to_i - s_mean

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
  return sim * ([co_rated, 50].min / 50.to_f)
end

def compute_similarities(ratings_array, mean_ratings)
  pair = Array.new
  similarities_hash = Hash.new
  i = 0
  j = 0
  until i > ratings_array.size - 1
    j = i + 1
    until j > ratings_array.size - 1
      pair = [ratings_array[i]["user"], ratings_array[j]["user"]]
      sim = similarity_between(ratings_array[i], ratings_array[j], mean_ratings)

      if !sim.to_f.nan?
        similarities_hash.store(pair, sim)
      end
      j += 1
    end
    i += 1
  end
  return similarities_hash
end

def user_standard_deviation(user, mean)
  sum = 0
  #puts "mean = #{mean}"

  user.each do |key, value|
    if key != "user"
      sum += (value.to_i - mean) ** 2
      #puts "value = #{value}"
    end
  end
  var = sum / (user.size - 1)
  return Math.sqrt(var)
end

def get_z_score(rating, mean)
  s_dev = user_standard_deviation(user, mean)
  return (rating - mean) / s_dev
end

def prediction_for_item(item, user_a, ratings_array, mean_ratings)
  upper_sum = 0
  lower_sum = 0
  mean = mean_ratings[user_a]
  s_dev = user_standard_deviation(user_a, mean)

  ratings_array.each do |user_b|
    next if user_b == user_a

    item_rating = user_b[item]
    next if item_rating.nil?

    z_score = get_z_score(item_rating, mean)
    sim = similarity_between(user_a, user_b, mean_ratings)
    upper_sum += z_score * sim
    lower_sum += sim
  end
  return upper_sum / lower_sum * s_dev + mean
end

class CollaborativeFiltering
  file = open("C:\\Users\\Juraj\\RubymineProjects\\blog\\ratingsFile")
  json = file.read
  ratings_array = JSON.parse(json)

  mean_ratings = get_users_mean(ratings_array)
  puts similarity_between(ratings_array[0], ratings_array[4], mean_ratings)
  puts compute_similarities(ratings_array, mean_ratings)
  puts user_standard_deviation(ratings_array[2], mean_ratings)
end