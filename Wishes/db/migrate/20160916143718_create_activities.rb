class CreateActivities < ActiveRecord::Migration[5.0]
  def change
    create_table :activities do |t|
      t.references :user, foreign_key: true
      t.references :wish, foreign_key: true
      t.integer :message_enum
      t.boolean :is_read

      t.timestamps
    end
  end
end
