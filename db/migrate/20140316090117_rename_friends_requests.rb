class RenameFriendsRequests < ActiveRecord::Migration
  def change
      rename_table :friend_requests, :friendship_requests
  end
end
