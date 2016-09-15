class CreateWishes < ActiveRecord::Migration[5.0]
  def change
    create_table :wishes do |t|
      t.string :title
      t.text :description
      t.integer :assign_to
      t.integer :fulfill_status
      t.datetime :expiry_at
      t.datetime :close_at

      t.timestamps
    end
  end
end
