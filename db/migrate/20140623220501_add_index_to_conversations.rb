class AddIndexToConversations < ActiveRecord::Migration
  def change
    add_index :conversations, [:user_id, :other_user_id, :ride_id]
  end
end
