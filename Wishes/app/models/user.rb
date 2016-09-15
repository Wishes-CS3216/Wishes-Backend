class User < ActiveRecord::Base
	has_many :wishes

	scope :get_user, -> (user_id, username, password) { where id: user_id, username: username, password: password }
end