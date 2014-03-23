class AddDriverRideIdToRelationships < ActiveRecord::Migration
  def change
    add_column :relationships, :driver_ride_id, :integer
  end
end
