class RenameColumnsInFriendRequest < ActiveRecord::Migration
  def change
    rename_column :FriendshipRequests, :from_user, :from_user_id
    rename_column :FriendshipRequests, :to_user, :to_user_id
  end
end
