class LeaderboardController < ApplicationController
	def show
		users = User.select(:id, :username, :display_name, :points)

		# 1. Rank users by points, take the top 10
		rank_users_by_points = users.order(points: :desc).limit(10)
		
		# 2. Rank users by number of wishes they fulfilled for others, take the top 10
		# This line returns hash where key is user_id, value is number, sorted in descending order and taking top 10
		user_ids_and_counts = Wish.where(fulfill_status: "Wish-er marked as fulfilled").group(:assigned_to).count.sort_by {|key, value| value}.reverse.first(10)
		# This few lines maps key (user_id) to user json with count.
		rank_users_by_fulfill_wishes_count = []
		user_ids_and_counts.each do |user_id, count|
			user_json = users.find(user_id).as_json
			user_json[:count] = count
			rank_users_by_fulfill_wishes_count.append(user_json)
		end

		# 3. Rank users by number of wishes, take the top 10
		user_id_and_wish_counts = Wish.group(:user_id).count.sort_by {|key, value| value}.reverse.first(10)
		# This few lines maps key (user_id) to user json with count.
		rank_users_by_wishes_count = []
		user_id_and_wish_counts.each do |user_id, count|
			user_json = users.find(user_id).as_json
			user_json[:count] = count
			rank_users_by_wishes_count.append(user_json)
		end

		# Render all ranked results
		render json: { by_points: rank_users_by_points, 
			           by_fulfill_wishes_count: rank_users_by_fulfill_wishes_count,
			           by_wishes_count: rank_users_by_wishes_count }
	end
end
