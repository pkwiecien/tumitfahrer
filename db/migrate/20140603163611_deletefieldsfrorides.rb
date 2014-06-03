class Deletefieldsfrorides < ActiveRecord::Migration
  def change
    remove_column :rides, :realtime_km
    remove_column :rides, :realtime_departure_time
    remove_column :rides, :duration
    remove_column :rides, :realtime_arrival_time
    remove_column :rides, :contribution_mode
    remove_column :rides, :is_finished
    remove_column :rides, :ride_owner_id
  end
end
