class RenameRideTypeinrides < ActiveRecord::Migration
  def change
    rename_column :rides, :rideType, :ride_type
  end

end
