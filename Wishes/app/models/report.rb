class Report < ApplicationRecord
	belongs_to :user

	validates :user, presence: true
	validates :reported_user_id, presence: true

	validate :users_must_exist

	def users_must_exist
		users = User.where('id IN (?)', [user_id, reported_user_id])
		if users.count != 2
			errors.add("Either user or reported user does not exist.")
		end
	end
end
