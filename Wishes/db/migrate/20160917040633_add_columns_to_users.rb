class AddColumnsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :posted_wishes_count, :integer
    add_column :users, :fulfilled_wishes_count, :integer
  end
end
