class Wish < ApplicationRecord
  belongs_to :user

  # Workflow:
  # When user makes a wish, there is no assigned_to_user and no fulfill_status
  # When assigned to user, both assigned_to_user and fulfill_status is initialized
  # Do-er will mark as fulfilled once he/she is done
  # Wish-er can then decide whether it is fulfilled or unfulfilled, where different actions might be taken.

  enum fulfill_status: {
    "Created wish, finding assignee" => 0,
    "In progress"                    => 1,
    "Do-er marked as fulfilled"      => 2,
    "Wish-er marked as fulfilled"    => 3,
    "Wish-er marked as unfulfilled"  => 4
  }

  validates :title, presence: true, length: {minimum: 5}
  validates :needs_meetup, inclusion: { in: [ true, false ] }
  validate :needs_meetup_must_have_geolocation
  validate :assigned_user_exists, :assigned_user_is_not_this_user

  def needs_meetup_must_have_geolocation
    if needs_meetup
      if address == nil || address.empty?
        errors.add(:address, "Cannot be empty.")
      end
      if latitude == nil
        errors.add(:latitude, "Cannot be empty.")
      end
      if longitude == nil
        errors.add(:longitude, "Cannot be empty.")
      end
    end
  end

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
