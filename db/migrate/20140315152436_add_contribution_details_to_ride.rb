class AddContributionDetailsToRide < ActiveRecord::Migration
  def change
    add_column :rides, :contribution_mode, :integer
    add_column :rides, :is_paid, :boolean
  end
end
