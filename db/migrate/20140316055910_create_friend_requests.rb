class CreateFriendRequests < ActiveRecord::Migration
  def change
    create_table :friend_requests do |t|
      t.integer :from_user
      t.integer :to_user

      t.timestamps
    end
  end
end
