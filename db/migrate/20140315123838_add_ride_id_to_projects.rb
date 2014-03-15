class AddRideIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :ride_id, :integer
  end
end
