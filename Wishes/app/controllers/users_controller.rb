class UsersController < ApplicationController
	def login
	end

	def create
	end

	def show
		@user = User.where(username: params[:username], password: params[:password])
		render json: @user 
	end

	def update
	end
end
