class AddRatingAverageToUser < ActiveRecord::Migration
  def change
    add_column :users, :rating_avg, :float
  end
end
