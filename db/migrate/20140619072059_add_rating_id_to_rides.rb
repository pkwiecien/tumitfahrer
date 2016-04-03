class AddRatingIdToRides < ActiveRecord::Migration
  def change
    add_column :rides, :rating_id, :integer
  end
end
