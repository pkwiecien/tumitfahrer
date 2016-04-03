class AddCancelTimeToRides < ActiveRecord::Migration
  def change
    add_column :rides, :last_cancel_time, :datetime
  end
end
