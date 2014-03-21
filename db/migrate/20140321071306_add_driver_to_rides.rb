class AddDriverToRides < ActiveRecord::Migration
  def change
    add_column :rides, :driver_id, :integer
  end
end
