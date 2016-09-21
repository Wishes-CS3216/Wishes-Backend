class WishesController < ApplicationController
	def index
		user_wishes = Wish.where(user_id: params[:user_id])
		user_wishes_as_json = []
		user_wishes.each do |wish|
			wish_json = wish.as_json
			if wish.assigned_to
				assignee = User.find(wish.assigned_to)
				wish_json[:assignee_display_name] = assignee.display_name
				wish_json[:assignee_phone] = assignee.phone
			else
				wish_json[:assignee_display_name] = nil
				wish_json[:assignee_phone] = nil
			end
			user_wishes_as_json.append(wish_json)
		end

		wishes_fulfilled_by_user = Wish.where(assigned_to: params[:user_id])
		wishes_fulfilled_by_user_as_json = []
		wishes_fulfilled_by_user.each do |wish|
			wish_json = wish.as_json
			wish_json[:wisher_contact_number] = wish.user.phone
			wishes_fulfilled_by_user_as_json.append(wish_json)
		end
		render json: { "self": user_wishes_as_json, "others": wishes_fulfilled_by_user_as_json }
	end

	def get_random_wishes
		total_number_of_wishes = 9
		if params[:latitude] && params[:longitude]
			# 1. Get random number X from 0 to 9 (uniformly distributed)
			number_of_wishes_that_needs_meetup = rand(10)

			# 2. X is the number of wishes that needs meetup. (Use geolocation to filter then take sample of size X)
			max_distance = 3 # For now let's set it to 3km... I planned for it to be a random value as well...
			wishes_that_needs_meetup = get_wishes_by_distance(params[:latitude], params[:longitude], params[:user_id], max_distance)
			wishes_that_needs_meetup = sample_wishes(wishes_that_needs_meetup, number_of_wishes_that_needs_meetup)
			
			# 3. (9-X) is the number of wishes that does not require meetup.
			number_of_wishes_that_does_not_need_meetup = total_number_of_wishes - wishes_that_needs_meetup.count
			wishes_that_does_not_need_meetup = get_wishes_without_distance(params[:user_id])
			wishes_that_does_not_need_meetup = sample_wishes(wishes_that_does_not_need_meetup, number_of_wishes_that_does_not_need_meetup)
			
			all_random_wishes = wishes_that_needs_meetup + wishes_that_does_not_need_meetup
			all_random_wishes.shuffle!
		else
			sql = "SELECT *
		           FROM wishes
		           WHERE user_id != #{params[:user_id]} AND assigned_to IS NULL"
		    wishes = Wish.find_by_sql(sql)
		    all_random_wishes = sample_wishes(wishes, total_number_of_wishes)
		end
		all_random_wishes_json = []
		all_random_wishes.each do |wish|
			wish_json = wish.as_json
			wish_json[:has_contact_number] = wish.user.phone.present?
			all_random_wishes_json.append(wish_json)
		end
		render json: all_random_wishes_json
	rescue Exception => e
		render json: { error: e }
	end

	def show
		wish = Wish.find(params[:wish_id])
		render json: wish
	rescue Exception => e
		render json: { error: e }
	end

	def create
		@user = User.find(params[:user_id])
		@wish = Wish.new(wish_params[:wish])
		User.transaction do
			Wish.transaction do
				@wish.user_id = @user.id
				@wish.save!
				@user.points -= 100
				@user.save!
				render json: { success: "Created wish", current_points_left: @user.points }
			end
		end
	rescue Exception => e
		if @wish && @wish.errors.present?
			render json: { message: "Validation failed", error: {wish: @wish.errors, user: @user.errors} }
		elsif @user && @user.errors.present?
			render json: { message: "Validation failed", error: @user.errors }
		else
			render json: { error: e }
		end
	end

	def update
		wish = Wish.find(params[:wish_id])
		if params[:assigned_to]
			if wish.assigned_to != nil
				render json: { error: "Wish is already assigned to someone." }
				return
			end
			Wish.transaction do
				wish.assigned_to = wish_params[:wish][:assigned_to]
				wish.fulfill_status = "In progress"
				wish.picked_at = DateTime.now
				wish.save!
				render json: { success: "Wish is assigned to user" }
			end
		elsif params[:fulfill_status]
			wisher = User.find(wish.user_id)
			doer = User.find(wish.assigned_to)
			Wish.transaction do
				User.transaction do
					case params[:wish][:fulfill_status]
					when "Do-er marked as fulfilled"
						if wish.fulfill_status == "In progress"
							wish.fulfill_status = params[:wish][:fulfill_status]
							wish.fulfilled_at = DateTime.now
						end
					when "Wish-er marked as fulfilled"
						if wish.fulfill_status
							wish.fulfill_status = params[:wish][:fulfill_status]
							wish.confirmed_at = DateTime.now
							doer.points += 100
							wisher.points += 30
						end
					when "Wish-er marked as unfulfilled"
						if wish.fulfill_status
							wish.fulfill_status = params[:wish][:fulfill_status]
							wish.confirmed_at = DateTime.now
						end
					else
						render json: { error: "No such fulfill_status." }
						return
					end
					wish.save!
					doer.save!
					wisher.save!
					render json: { success: "Updated fulfill status." }
				end
			end
		end
	rescue Exception => e
		if @wish.errors.present?
			render json: { message: "Validation failed", error: @wish.errors }
		else
			render json: { error: e }
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
			                  :needs_meetup, :address, :latitude, :longitude]})
	end

	def get_wishes_by_distance(latitude, longitude, user_id, max_distance)
		# Here's the SQL statement that will find the closest locations
		# that are within a radius of max_distance (in km) to the (latitude, longitude) coordinate.
		# It calculates the distance based on the latitude/longitude of that row and the target latitude/longitude,
		# and then asks for only rows where the distance value is less than max_distance,
		# with additional filters like not ownself's wish and wish is not assigned to anyone,
		# then orders the whole query by distance.
		sql = "SELECT *, ( 6371 * acos( cos( radians(#{latitude}) ) * cos( radians( latitude ) ) * cos( radians( longitude ) - radians(#{longitude}) ) + sin( radians(#{latitude}) ) * sin( radians( latitude ) ) ) ) AS distance
		       FROM wishes
		       WHERE user_id != #{user_id} AND assigned_to IS NULL AND needs_meetup = 1
		       HAVING distance < #{max_distance}
		       ORDER BY distance"
		wishes = Wish.find_by_sql(sql)
	end

	def get_wishes_without_distance(user_id)
		sql = "SELECT *
		       FROM wishes
		       WHERE user_id != #{user_id} AND assigned_to IS NULL AND needs_meetup = 0"
		wishes = Wish.find_by_sql(sql)
	end

	def sample_wishes(all_wishes, sample_size)
		result = []
		1.upto(sample_size) do |i|
			if all_wishes.count > 0
				random_index = rand(all_wishes.count)
				random_wish = all_wishes[random_index]
				result.append(random_wish)
				all_wishes -= [random_wish]
			end
		end
		result
	end
end
