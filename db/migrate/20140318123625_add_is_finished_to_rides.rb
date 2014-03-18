class AddIsFinishedToRides < ActiveRecord::Migration
  def change
    add_column :rides, :is_finished, :boolean
  end
end
