class MessageSerializer < ActiveModel::Serializer
  attributes :id, :content, :is_seen, :sender_id, :receiver_id, :created_at, :updated_at

end
