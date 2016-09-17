class SessionsController < ApplicationController
	def create
    username = params[:session][:username]
    password = params[:session][:password]
    user = User.user_login(params[:username], params[:password])

    if user.present?
			user = user.first
			user.generate_authentication_token!
			user.save
			render json: user, status: 200
		else
			render json: { errors: "Invalid email or password" }, status: 422
		end
  end

  def destroy
    user = User.find_by(auth_token: params[:auth_token])
    user.generate_authentication_token!
    user.save
    head 204
  end
end
