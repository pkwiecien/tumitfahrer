class AddDistanceToRides < ActiveRecord::Migration
  def change
    add_column :rides, :distance, :float
  end
end
