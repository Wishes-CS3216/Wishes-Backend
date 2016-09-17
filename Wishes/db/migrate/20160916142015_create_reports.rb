class CreateReports < ActiveRecord::Migration[5.0]
  def change
    create_table :reports do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.references :reported_user, references: :users, index: true

      t.timestamps
    end
  end
end
