class RemoveOldFieldsFromMessages < ActiveRecord::Migration
  def change
    add_column :messages, :conversation_id, :integer
    remove_column :messages, :sender_id
    remove_column :messages, :receiver_id
    remove_column :messages, :ride_id
  end
end
