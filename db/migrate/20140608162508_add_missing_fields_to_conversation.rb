class AddMissingFieldsToConversation < ActiveRecord::Migration

  def change
    add_column :conversations, :user_id, :integer
    add_column :conversations, :other_user_id, :integer
  end
end
