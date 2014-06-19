class AddCarToRides < ActiveRecord::Migration
  def change
    add_column :rides, :car, :string
  end
end
