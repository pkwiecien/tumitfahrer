class CreateFriendRequests < ActiveRecord::Migration
  def change
    create_table :FriendshipRequests do |t|
      t.integer :from_user
      t.integer :to_user

      t.timestamps
    end
  end
end
