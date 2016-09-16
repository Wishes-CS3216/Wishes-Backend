class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :wish

  scope :get_activities, -> (user_id) { where user_id: user_id }
end
