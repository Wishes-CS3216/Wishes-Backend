class User < ApplicationRecord
	has_many :wishes
	has_many :reports
	has_many :activities

	validates :username, presence: true, uniqueness: true
	validates :password, presence: true

	scope :user_show, -> (user_id, username, password) { where id: user_id, username: username, password: password }
	scope :user_login, -> (username, password) { where username: username, password: password }

	before_save { |user| user.username = user.username.downcase }
end