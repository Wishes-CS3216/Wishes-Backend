class CreateWishes < ActiveRecord::Migration[5.0]
  def change
    create_table :wishes do |t|
      t.string :title
      t.text :description
      t.references :user, references: :users, index: true
      t.integer :assigned_to
      t.integer :fulfill_status
      t.datetime :expiry_at
      t.datetime :close_at

      t.timestamps
    end
  end
end
