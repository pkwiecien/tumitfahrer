class CreateRideSearches < ActiveRecord::Migration
  def change
    create_table :ride_searches do |t|
      t.integer :user_id
      t.string :departure_place
      t.string :destination
      t.datetime :departure_time

      t.timestamps
    end
  end
end
