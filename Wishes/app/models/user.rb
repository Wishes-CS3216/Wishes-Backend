class User < ActiveRecord::Base
	has_many :wishes

	validates :username, presence: true, uniqueness: true
	validates :password, presence: true

	scope :get_user, -> (user_id, username, password) { where id: user_id, username: username, password: password }
	scope :get_user, -> (username, password) { where username: username, password: password }
end