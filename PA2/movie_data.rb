require 'movie_test'

##
# This class represents MovieData with a lot of methods

class MovieData
	attr_accessor :movie_reviews
	attr_accessor :user_reviews
	attr_accessor :movie_user_reviews
	
	#for test dataset
	attr_accessor :test_movie_user_reviews
	
	##
	# constructor with folder using the u.data file in this folder
	def initialize(folder)
		set_reviews
   		load_data(folder)
   	end
   	
   	##
   	# constructor with folder and filename, create training set and test set
   	def initialize(folder, u1)
		set_reviews
   		load_data(folder, u1)
   	end

	##
	# initialize the instance variable
	def set_reviews
		@movie_reviews = Hash.new()
   		@user_reviews = Hash.new()
   		@movie_user_reviews = Hash.new()
		@test_movie_reviews = Hash.new()
   		@test_user_reviews = Hash.new()
   		@test_movie_user_reviews = Hash.new()
	end

	##
	# load data from u.data, only create training set
	def load_data(folder)
   		f = open(folder+"/u.data")
   		f.each_line do |line|
        	readin = line.split(" ").map{|i| i.to_i}
        	#readin[0]:movieID
        	#readin[1]:userID
        	#readin[2]:rating
        	#readin[3]:time
        	update_movie_reviews(readin)
        	update_user_reviews(readin)
        	update_movie_user_reviews(readin)
    	end
	end
	
	##
	# load data, create training set and test set
	def load_data(folder, u1)
   		f_training = open(folder + "/" + u1 + ".base")
   		f_test = open(folder + "/" + u1 + ".test")
   		80000.times do
        	readin = f_training.readline.split(" ").map{|i| i.to_i}
        	update_movie_reviews(readin)
        	update_user_reviews(readin)
        	update_movie_user_reviews(readin)
        end
        20000.times do
        	readin = f_test.readline.split(" ").map{|i| i.to_i}
        	update_test_movie_user_reviews(readin)
    	end
	end
	
	##
	# create a hash with movie id as key, and value is also a hash with user id as key
	def update_movie_reviews(readin)
		temp = Hash.new()
		if @movie_reviews.has_key?(readin[0])
			temp = @movie_reviews[readin[0]]
		end
		temp[readin[1]] = [readin[2], readin[3]]
		@movie_reviews[readin[0]] = temp
	end
	
	##
	# create a hash with user id as key, and value is also a hash with movie id as key
	def update_user_reviews(readin)
		temp = Hash.new()
		if @user_reviews.has_key?(readin[1])
			temp = @user_reviews[readin[1]]
		end
		temp[readin[0]] = [readin[2], readin[3]]
		@user_reviews[readin[1]] = temp
	end
	
	##
	# create a hash with movie id and user id as key, storing training data set
	def update_movie_user_reviews(readin)
		@movie_user_reviews[[readin[0], readin[1]]] = [readin[2], readin[3]]
	end
	
	##
	# create a hash with movie id and user id as key, storing test data set
	def update_test_movie_user_reviews(readin)
		@test_movie_user_reviews[[readin[0], readin[1]]] = [readin[2], readin[3]]
	end
	
	##
	# return the popularity of the movie
	# equal the number of people who have watched the movie
	def popularity(movie_id)
		return @movie_reviews[movie_id].length
	end
	
	##
	# return the popularity of all movies
	def popularity_list
		list = Hash.new()
  		@movie_reviews.keys.each do |movieID|
  			list[movieID] = popularity(movieID)
  		end
  		sorted_list = list.sort {|x, y| y[1] <=> x[1]}
  		return sorted_list
	end
	
	##
	# return the similarity of two users
	def similarity(user1, user2)
		result = 0
		movie_user1 = @user_reviews[user1]
		movie_user2 = @user_reviews[user2]
		movie_user1.keys.each do |movieID|
			if movie_user2.has_key?(movieID)
				result += 5 - (movie_user1[movieID][0] - movie_user2[movieID][0]).abs
			end
  		end
		return result
	end 
	
	##
	# return the list of similarity of all other users with a user
	def most_similar(user1)
		result = Hash.new()
  		@user_reviews.keys.each do |userID|
			if user1 != userID
				result[userID] = similarity(user1, userID)
	  		end
	  	end
	  	sorted_result = result.sort {|x, y| y[1] <=> x[1]}
		return sorted_result
	end

	##
	# return the rating of the user and movie
	def rating(u, m)
		if @movie_user_reviews.has_key?([m, u])
			return @movie_user_reviews[[m, u]][0]
		else
			return 0
		end
	end

	##
	# predict the rating of the user and movie
	def predict(u, m)
		most_similar_u = most_similar(u)
		most_similar_u.each do |mu|
			if @user_reviews[mu[0]].has_key?(m)
				return @movie_user_reviews[m, most_similar_u[0]][0]
			end
		end
	end

	##
	# return the list of movies the user have watched
	def movies(u)
		if @user_reviews.has_key?(u)
			return @user_reviews[u].keys
		else
			return []
		end
	end
	
	##
	# return the list of users that have watched movie
	def viewers(w)
		if @movie_reviews.has_key?(w)
			return @movie_reviews[w].keys
		else
			return []
		end
	end
	
	##
	# run predict for the first k rating
	def run_test(k)
		results = MovieTest.new
		@test_movie_user_reviews.keys[1, k].each do |comb_key|
			p = predict(comb_key[1], comb_key[0])
			results.movie_user_rating_predictions[comb_key] = [@test_movie_user_reviews[comb_key][0], p]
		end
		return results
	end
	
	##
	# run predict for all rating
	def run_test
		run_test(20000)
	end
	
end