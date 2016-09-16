class Wish < ApplicationRecord
  belongs_to :user

  scope :get_wishes, -> (user_id) { where user_id: user_id }
end
