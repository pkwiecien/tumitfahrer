class ChangeStatusTypeAddMessageInTable < ActiveRecord::Migration
  def change
    change_column :notifications, :status, :string
    add_column :notifications, :message, :string
  end
end
