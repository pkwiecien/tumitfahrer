class CreateRides < ActiveRecord::Migration
  def change
    create_table :rides do |t|
      t.string :departure_place
      t.string :destination
      t.datetime :departure_time
      t.integer :free_seats
      t.integer :driver_id
      t.string :meeting_point

      t.timestamps
    end
    add_index :rides, [:driver_id]
  end
end
