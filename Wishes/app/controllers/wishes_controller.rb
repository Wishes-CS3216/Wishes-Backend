class WishesController < ApplicationController
	def index
		@user_wishes = Wish.where(user_id: params[:user_id])

		@wishes_fulfilled_by_user = Wish.where(assigned_to: params[:user_id])
		@wishes_fulfilled_by_user_as_json = []
		@wishes_fulfilled_by_user.each do |wish|
			wish_json = wish.as_json
			wish_json[:wisher_contact_number] = wish.user.phone
			@wishes_fulfilled_by_user_as_json.append(wish_json)
		end
		render json: { "self": @user_wishes, "others": @wishes_fulfilled_by_user_as_json }
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
			wish = wish.first
			wish_json = wish.as_json
			wish_json[:wisher_contact_number] = wish.user.phone
			render json: wish_json
		else
			render json: { error: "No such wish matching to this user's id" }
		end
	end

	def wish_params
		params.permit({wish: [:title, :description, :assigned_to]})
	end
end
