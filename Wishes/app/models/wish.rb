class Wish < ApplicationRecord
  belongs_to :user

  # Workflow:
  # When user makes a wish, there is no assigned_to_user and no fulfill_status
  # When assigned to user, both assigned_to_user and fulfill_status is initialized
  # Do-er will mark as fulfilled once he/she is done
  # Wish-er can then decide whether it is fulfilled or unfulfilled, where different actions might be taken.

  enum fulfill_status: {
    "In progress"                   => 0,
    "Do-er marked as fulfilled"     => 1,
    "Wish-er marked as fulfilled"   => 2,
    "Wish-er marked as unfulfilled" => 3
  }

  validates :title, presence: true, length: {minimum: 5}
  validate :assigned_user_exists, :assigned_user_is_not_this_user

  def assigned_user_exists
    if assigned_to && User.where(id: assigned_to).empty?
      errors.add(:assigned_to, "Assigned user does not exist.")
    end
  end

  def assigned_user_is_not_this_user
    if assigned_to && assigned_to == user_id
      errors.add(:assigned_to, "Cannot assign your wish to yourself.")
    end
  end
end
