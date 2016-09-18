class WishesController < ApplicationController
	def index
		@wishes = Wish.where(user_id: params[:user_id])
		render json: @wishes
	end

	def create
		@wish = Wish.new(wish_params[:wish])
		Wish.transaction do
			@wish.user_id = params[:user_id]
			@wish.save!
			render json: { success: "Created wish" }
		end
	rescue Exception
		if @wish.errors.present?
			render json: { message: "Validation failed", error: @wish.errors }
		else
			render json: { error: "Unknown error" }
		end
	end

	def show
		@wish = Wish.where(id: params[:wish_id], user_id: params[:user_id])
		return_wish_as_json(@wish)
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
			render json: wish.first
		else
			render json: { error: "No such wish matching to this user's id" }
		end
	end

	def wish_params
		params.permit({wish: [:title, :description, :assigned_to]})
	end
end
