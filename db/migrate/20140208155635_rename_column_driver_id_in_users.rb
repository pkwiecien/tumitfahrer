class RenameColumnDriverIdInUsers < ActiveRecord::Migration
  def change
    rename_column :rides, :driver_id, :user_id
  end
end
