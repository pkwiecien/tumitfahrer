class AddRideTypeToRideSearches < ActiveRecord::Migration
  def change
    add_column :ride_searches, :ride_type, :integer
  end
end
