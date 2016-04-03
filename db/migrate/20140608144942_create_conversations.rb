class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.integer :ride_id
      t.integer :user_id
      t.integer :other_user_id

      t.timestamps
    end
  end
end
