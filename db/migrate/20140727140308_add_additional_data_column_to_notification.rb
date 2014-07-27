class AddAdditionalDataColumnToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :extra, :integer
  end
end
