class ReportsController < ApplicationController
	def create
		@report = Report.new(report_params)
		Report.transaction do
			@report.save!
			render json: {status: "Created report successfully"}
		end
	end
private
	def report_params
		params.permit([:user_id, :reported_user_id])
	end
end