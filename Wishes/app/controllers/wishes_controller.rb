class WishesController < ApplicationController
	def index
		@wishes = Wish.get_wishes(user_id: params[:user_id])
		render json: @wishes
	end

	def create
		@wish = Wish.new(wish_params)
		Wish.transaction do
			@wish.save!
		end
	end

	def show
		#@wish = Wish.where(id: params[:wish_id])
		#render json: @wish 
	end

	def edit
	end

	def update
	end
private
	def wish_params
		params.permit([:user_id, :title, :description])
	end
end
