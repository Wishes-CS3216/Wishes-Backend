class WishesController < ApplicationController
	def index
		@wishes = Wish.where(user_id: params[:user_id])
		render json: @wishes
	end

	def create
		@wish = Wish.new(wish_params)
		Wish.transaction do
			@wish.save!
		end
	end

	def show
		@wish = Wish.find(params[:wish_id])
		return_wish_as_json(@wish)
	end

	def edit
	end

	def update
	end
private
	def return_wish_as_json(wish)
		if wish.present?
			render json: wish.first
		else
			render json: { error: "No such wish" }
		end
	end

	def wish_params
		params.permit([:user_id, :title, :description])
	end
end
