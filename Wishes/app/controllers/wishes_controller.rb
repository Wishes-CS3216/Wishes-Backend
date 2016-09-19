class WishesController < ApplicationController
	def index
		@user_wishes = Wish.where(user_id: params[:user_id])

		@wishes_fulfilled_by_user = Wish.where(assigned_to: params[:user_id])
		@wishes_fulfilled_by_user_as_json = []
		@wishes_fulfilled_by_user.each do |wish|
			wish_json = wish.as_json
			wish_json[:wisher_contact_number] = wish.user.phone
			@wishes_fulfilled_by_user_as_json.append(wish_json)
		end
		render json: { "self": @user_wishes, "others": @wishes_fulfilled_by_user_as_json }
	end

	def create
		@user = User.find(params[:user_id])
		@wish = Wish.new(wish_params[:wish])
		User.transaction do
			Wish.transaction do
				@wish.user_id = params[:user_id]
				@wish.save!
				@user.points -= 100
				@user.save!
				render json: { success: "Created wish", current_points_left: @user.points }
			end
		end
	rescue Exception
		if @wish
			render json: { message: "Validation failed", error: {wish: @wish.errors, user: @user.errors} }
		elsif @user
			render json: { message: "Validation failed", error: @user.errors }
		else
			render json: { error: "Unknown error" }
		end
	end

	def update
		@wish = Wish.find(params[:wish_id])
		if params[:assigned_to] && params[:wish_id]
			Wish.transaction do
				@wish.update!(wish_params[:wish])
				render json: { success: "Wish is assigned to user" }
			end
		end
	rescue Exception
		if @wish.errors.present?
			render json: { message: "Validation failed", error: @wish.errors }
		else
			render json: { error: "Unknown error" }
		end
	end

private
	def return_wish_as_json(wish)
		if wish.present?
			wish = wish.first
			wish_json = wish.as_json
			wish_json[:wisher_contact_number] = wish.user.phone
			render json: wish_json
		else
			render json: { error: "No such wish matching to this user's id" }
		end
	end

	def wish_params
		params.permit({wish: [:title, :description, :assigned_to, 
			                  :requires_meetup, :address, :latitude, :longitude]})
	end

	def distance(latitude, longitude, user_id, max_distance)
		# Here's the SQL statement that will find the closest locations
		# that are within a radius of max_distance (in km) to the (latitude, longitude) coordinate.
		# It calculates the distance based on the latitude/longitude of that row and the target latitude/longitude,
		# and then asks for only rows where the distance value is less than max_distance,
		# with additional filters like not ownself's wish and wish is not assigned to anyone,
		# then orders the whole query by distance.
		sql = "SELECT *, ( 6371 * acos( cos( radians(#{latitude}) ) * cos( radians( latitude ) ) * cos( radians( longitude ) - radians(#{longitude}) ) + sin( radians(#{latitude}) ) * sin( radians( latitude ) ) ) ) AS distance
		       FROM wishes
		       WHERE user_id != #{user_id} AND assigned_to IS NULL
		       HAVING distance < #{max_distance}
		       ORDER BY distance"
		wishes = Wish.find_by_sql(sql)
	end
end
