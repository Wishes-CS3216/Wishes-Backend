class UsersController < ApplicationController
	skip_before_action :restrict_access, only: [ :login, :create ]

	def login
		user = User.find_by(username: params[:username])
		if user.nil?
			render json: { message: "Authentication failed" }
		elsif user.authenticate(params[:password])
			user_json = user.as_json
			user_json[:posted_wishes_count] = user.wishes.count
			user_json[:fulfilled_others_wishes_count] = Wish.where(assigned_to: user.id, fulfill_status: "Wish-er marked as fulfilled").count
			render json: user_json
		else
			render json: { message: "Authentication failed" }
		end
	end

	def create
		@user = User.new(user_params[:user])
		User.transaction do
			@user.points = 300
			@user.email_verified = false
			@user.save!
			render json: { success: "Created user" }
		end
	rescue Exception
		if @user
			render json: { message: "Validation failed", error: @user.errors }
		else
			render json: { message: "Unknown error" }
		end
	end

	def show
		user = User.find(params[:user_id])
		got_claim_bonus = false
		if !user.claimed_daily_bonus
			User.transaction do
				user.points += 30
				user.claimed_daily_bonus = true
				got_claim_bonus = true
				user.save!
			end
		end
		user_json = user.as_json
		user_json[:posted_wishes_count] = user.wishes.count
		user_json[:fulfilled_others_wishes_count] = Wish.where(assigned_to: user.id, fulfill_status: "Wish-er marked as fulfilled").count
		user_json[:got_claim_bonus] = got_claim_bonus
		render json: user_json
	end

	def update
		@user = User.find(params[:user_id])
		# Attempt to change password if username, old and new password is present in params
		if params[:username].present? && params[:old_password].present? && params[:new_password].present?
			if @user.username != params[:username].downcase
				render json: { error: "Username does not match." }
			elsif !@user.authenticate(params[:old_password])
				render json: { error: "Your old password does not match." }
			else
				User.transaction do
					@user.password = params[:new_password]
					@user.save!
					render json: { success: "Updated password" }
				end
			end
		# Attempt to update user info if BOTH old and new password is NOT present
		elsif params[:old_password] == nil && params[:old_password] == nil
			# Store copy of user to see if anything changed after update.
			@user_copy = User.find(params[:user_id])
			User.transaction do
				@user.update!(user_update_params[:user])
			end
			if (@user_copy.as_json == @user.as_json)
				render json: { warning: "Nothing was updated" }
			else
				render json: { success: "Updated user" }
			end
		# Catch any other possible combination of arguments
		else
			render json: { error: "Wrong arguments" }
		end
	rescue Exception
		if @user.errors.present?
			render json: { message: "Validation failed", error: @user.errors }
		else
			render json: { error: "Update failed" }
		end
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
		params[:user][:password] = params[:password]
		params.permit({user: [:username, :password, :phone, :email, :display_name]})
	end

	def user_update_params
		params.permit({user: [:username, :phone, :email, :display_name]})
	end
end
