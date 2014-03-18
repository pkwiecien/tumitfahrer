class ChangeDurationColumnInRides < ActiveRecord::Migration
  def change
    change_column :rides, :duration, :float
  end
end
