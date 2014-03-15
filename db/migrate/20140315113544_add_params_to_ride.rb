class AddParamsToRide < ActiveRecord::Migration
  def change
    add_column :rides, :realtime_km, :float
    add_column :rides, :price, :float
    add_column :rides, :realtime_departure_time, :datetime
    add_column :rides, :duration, :float
    add_column :rides, :realtime_arrival_time, :datetime
  end
end
