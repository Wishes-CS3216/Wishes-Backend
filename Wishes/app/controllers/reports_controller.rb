class ReportsController < ApplicationController
	def create
		@report = Report.new(report_params)
		Report.transaction do
			@report.save!
		end
	end
private
	def report_params
		params.permit([:reporter_id, :reportee_id])
	end
end