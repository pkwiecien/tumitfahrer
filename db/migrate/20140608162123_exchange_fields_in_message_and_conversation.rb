class ExchangeFieldsInMessageAndConversation < ActiveRecord::Migration
  def change

    remove_column :conversations, :user_id
    remove_column :conversations, :other_user_id
    add_column :messages, :sender_id, :integer
    add_column :messages, :receiver_id, :integer

  end
end
