class SimpleConversationSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :other_user_id, :ride_id, :last_message_time, :last_sender_id

  def last_message_time
    object.last_message_time
  end

  def last_sender_id
    object.last_sender_id
  end

end
