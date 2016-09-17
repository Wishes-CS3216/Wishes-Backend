class UsersController < ApplicationController
	def login
		@user = User.get_user(params[:username], params[:password])
		return_user_as_json(@user)
	end

	def create
		@user = User.new(user_params)
		User.transaction do
			@user.points = 200
			@user.save!
		end
	end

	def show
		@user = User.get_user(params[:user_id], params[:username], params[:password])
		return_user_as_json(@user)
	end

	def update
	end

private
	def return_user_as_json(user)
		if user.present?
			render json: user.first
		else
			render json: { error: "No such user" }
		end
	end

	def user_params
		params.permit([:username, :password])
	end
end
