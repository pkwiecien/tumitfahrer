class AddRidetypetorides < ActiveRecord::Migration
  def change
    add_column :rides, :ride_type, :integer
  end
end
