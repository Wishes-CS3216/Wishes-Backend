class UsersController < ApplicationController
	def login
	end

	def create
		@user = User.new(user_params)
		User.transaction do
			@user.save!
		end
	end

	def show
		@user = User.get_user(params[:user_id], params[:username], params[:password])
		if @user.present?
			render json: @user.first
		else
			render json: {error: "No such user"}
		end
	end

	def update
	end

private

	def user_params
		params.permit([:username, :password])
	end
end
