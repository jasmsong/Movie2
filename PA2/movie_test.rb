##
# This class represents MovieTest with a lot of method to test the predict error

class MovieTest
	attr_accessor :movie_user_rating_predictions
	
	##
	# initialize, create the instance variable
	def initialize
		@movie_user_rating_predictions = Hash.new
   	end
	
	##
	# returns the average predication error (which should be close to zero)
	def mean
		results = 0
		@movie_user_rating_predictions.values.each do |v|
			results += (v[0] - v[1]).abs
		end
		results = results/@movie_user_rating_predictions.length
		return results
	end
	
	##
	# returns the standard deviation of the error
	def stddev
		results = 0
		mn = mean
		@movie_user_rating_predictions.values.each do |v|
			results += ((v[0] - v[1]).abs - mn) ** 2
		end
		results = sqrt(results/@movie_user_rating_predictions.length)
		return results		
	end
	
	##
	# returns the root mean square error of the prediction
	def rms
		results = 0
		@movie_user_rating_predictions.values.each do |v|
			results += (v[0] - v[1]).abs ** 2
		end
		results = sqrt(results/@movie_user_rating_predictions.length)
		return results
	end 
	
	##
	# returns an array of the predictions in the form [u,m,r,p]
	def to_a
		results = []
		@movie_user_rating_predictions.each do |k, v|
			results.push([k[1], k[0], v[0], v[1]])
		end
		return results
	end
	
end