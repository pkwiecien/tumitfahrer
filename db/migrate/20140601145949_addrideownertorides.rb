class Addrideownertorides < ActiveRecord::Migration
  def change
    add_column :rides, :ride_owner_id, :integer
  end
end
