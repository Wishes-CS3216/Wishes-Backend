class ActivitiesController < ApplicationController
	def index
		@activities = Activity.get_activities(user_id: params[:user_id])
		render json: @activities
	end

	def archive
	end
end
