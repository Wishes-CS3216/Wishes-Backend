class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :username
      t.string :password
      t.string :phone
      t.string :display_name
      t.string :random_name
      t.integer :points

      t.timestamps
    end
  end
end
