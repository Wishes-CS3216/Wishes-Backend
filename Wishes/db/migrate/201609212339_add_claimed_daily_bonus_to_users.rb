class AddClaimedDailyBonusToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :claimed_daily_bonus, :boolean
  end
end