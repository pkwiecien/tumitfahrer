class AddRegularRideIdToRides < ActiveRecord::Migration
  def change
    add_column :rides, :regular_ride_id, :integer
  end
end
