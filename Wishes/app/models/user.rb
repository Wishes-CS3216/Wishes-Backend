class User < ApplicationRecord
	has_many :wishes
	has_many :reports
	has_many :activities

	has_secure_password
	validates :username, presence: true, uniqueness: true
	validates :auth_token, uniqueness: true
	validates :points, numericality: { greater_than_or_equal_to: 0 }

	before_validation { |user| user.username = user.username.downcase }
	before_create :generate_authentication_token!

private
	def generate_authentication_token!
    begin
      self.auth_token = SecureRandom.hex(32)
    end while self.class.exists?(auth_token: auth_token)
  end
end
