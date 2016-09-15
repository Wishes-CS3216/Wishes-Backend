class WishesController < ApplicationController
	def index
		@wishes = Wish.where(user_id: params[:user_id]);
		render json: @wishes
	end

	def create
		@wish = Wish.create(user_id: params[:user_id], title: params[:title])
	end

	def show
		#@wish = Wish.where(id: params[:wish_id])
		#render json: @wish 
	end

	def edit
	end

	def update
	end
end
