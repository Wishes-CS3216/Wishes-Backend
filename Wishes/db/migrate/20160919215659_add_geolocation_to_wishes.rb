class AddGeolocationToWishes < ActiveRecord::Migration[5.0]
  def change
    add_column :wishes, :requires_meetup, :boolean
    add_column :wishes, :address, :string
    add_column :wishes, :latitude, :decimal, precision: 9, scale: 6
    add_column :wishes, :longitude, :decimal, precision: 9, scale: 6
  end
end
