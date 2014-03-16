class RenameColumnsInFriendRequest < ActiveRecord::Migration
  def change
    rename_column :friend_requests, :from_user, :from_user_id
    rename_column :friend_requests, :to_user, :to_user_id
  end
end
