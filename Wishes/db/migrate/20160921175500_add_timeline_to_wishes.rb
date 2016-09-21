class AddTimelineToWishes < ActiveRecord::Migration[5.0]
  def change
    add_column :wishes, :picked_at, :datetime
    add_column :wishes, :fulfilled_at, :datetime
    add_column :wishes, :confirmed_at, :datetime
  end
end