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
		@user = User.where(username: params[:username], password: params[:password])
		render json: @user 
	end

	def update
	end

private

	def user_params
		params.permit([:username, :password])
	end
end
