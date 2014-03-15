class AddFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :rank, :integer
    add_column :users, :unbound_contributions, :integer
    add_column :users, :exp, :integer
  end
end
