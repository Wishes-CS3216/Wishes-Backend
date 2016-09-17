class UsersController < ApplicationController
	def login
		@user = User.user_login(params[:username], params[:password])
		return_user_as_json(@user)
	end

	def create
		@user = User.new(user_params)
		User.transaction do
			@user.points = 0
			@user.save!
			render json: { success: "Created user" }
		end
	end

	def show
		@user = User.user_show(params[:user_id], params[:username], params[:password])
		return_user_as_json(@user)
	end

	def update
	end

private
	def return_user_as_json(user)
		if user.present?
			user = user.first
			user_hash = user.as_json
			user_hash[:number_of_wishes] = user.wishes.count
			user_hash[:number_of_wishes_fulfilled] = Wish.where(assigned_to: user.id, fulfill_status: "Wish-er marked as fulfilled").count
			render json: user_hash
		else
			render json: { error: "No such user" }
		end
	end

	def user_params
		params.permit([:username, :password, :phone, :email, :display_name])
	end
end
