class User < ApplicationRecord
	has_many :wishes
	has_many :reports
	has_many :activities

	validates :username, presence: true, uniqueness: true
	validates :password, presence: true

	scope :get_user, -> (user_id, username, password) { where id: user_id, username: username, password: password }
	scope :get_user, -> (username, password) { where username: username, password: password }
end