require 'json'
require 'pry'

def dice_coefficient(game_tags, user_tags)
  conjunct = 0

  return 0 if game_tags.empty? || user_tags.empty?
  if game_tags.size == 1
    game_tags = [game_tags]
  else
    game_tags = game_tags.split(";")
  end
  user_tags = [user_tags] if user_tags.size == 1

  game_tags.each do |gt|
    user_tags.each do |ut|
      if gt.downcase == ut.downcase
        conjunct += 1
        next
      end
    end
  end

  return (2 * conjunct) / (game_tags.size * user_tags.size)
end

def compute_tags_similarity(games_array, user_profile)
  tags_sim = Hash.new

  games_array.each do |game|
    game_tags = game["tags"]
    user_tags = user_profile["tags"]

    dice_coeff = dice_coefficient(game_tags, user_tags)
    key = [user_profile["user"], game["game"]]
    tags_sim.store(key, dice_coeff)
  end
  return tags_sim
end

def term_count(term, description)
  return 0 if description.nil?

  count = 0
  words = description.split
  words.each do |word|
    count += 1 if word.downcase == term.downcase
    #p word
    #p term
  end
  return count
end

def contains_term(term, description)
  return false if description.nil?

  words = description.split
  words.each do |word|
    return true if word.downcase == term.downcase
  end
  return false
end

def inverse_document_frequency(term, games_array)
  docs_with_t = 0
  games_array.each do |game|
    desc = game["description"]
    docs_with_t += 1 if contains_term(term, desc)
  end
  docs_all = games_array.size
  return docs_with_t > 0 ? Math.log(docs_all / docs_with_t) : 0
end

def idf_for_all_words(games_array)
  idfs = Hash.new

  games_array.each do |game|
    words = game["description"].split
    words.each do |word|
      next if idfs.has_key?(word)
      idf = inverse_document_frequency(word, games_array)
      idfs.store(word.downcase, idf)
    end
  end
  return idfs
end

def term_frequency(term, description)
  return 0 if description.nil? || description.empty?
  return term_count(term, description) / description.size.to_f
end

def tfidf_vector(words, idfs, description)
  vector_tfidf = Hash.new

  #p idfs

  words.each do |word|
    idf = idfs[word]

    #p word
    #p term_frequency(word, description)
    #p idf

    tfidf = term_frequency(word, description) * idf
    vector_tfidf.store(word, tfidf)
  end
  return vector_tfidf
end

def vector_norm(vector)
  sum = 0
  vector.each do |x|
    sum += x ** 2
  end
  return Math.sqrt(result)
end

def cosine_similarity(user_vector, game_vector)
  return 0 if user_vector.nil? || user_vector.empty?
  return 0 if game_vector.nil? || game_vector.empty?

  scalar_product = 0
  user_vector.each do |u_key, u_value|
    game_vector.each do |g_key, g_value|
      #p "u_key = #{u_key}, u_value = #{u_value}"
      #p "g_key = #{g_key}, g_value = #{g_value}"
      scalar_product += u_value * g_value if u_key.downcase == g_key.downcase
    end
  end

  return scalar_product / vector_norm(user_vector) * vector_norm(game_vector)
end

def open_file(path)
  file = open(path)
  json = file.read
  return JSON.parse(json)
end

def predictions_for_user(user, games_array)
  predictions = Hash.new
  user_vector = user["keywords"]
  idfs = idf_for_all_words(games_array)

  games_array.each do |game|
    game_name = game["game"]
    desc = game["description"]
    game_vector = desc.split
    user_tfidf_vector = tfidf_vector(user_vector, idfs, desc)
    game_tfidf_vector = tfidf_vector(game_vector, idfs, desc)
    keywords_sim = cosine_similarity(user_tfidf_vector, game_tfidf_vector)
    tags_sim = compute_tags_similarity(games_array, user)
    pred = tags_sim * 3 + keywords_sim
    predictions.store(game_name, pred)
  end

  return predictions
end

def compute_predictions()
  user_profiles = open_file("../../user_profiles")
  games_array = open_file("../../Games-final")

  predictions_all = Hash.new
  user_profiles.each do |user|
    username = user["user"]
    pred = predictions_for_user(user, games_array)
    predictions_all.store(username, pred)
  end

  file = File.open("../../predictions_cb", "w")
  file.write(predictions_all)
end

class ContentBasedFiltering
  compute_predictions
end