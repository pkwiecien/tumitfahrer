class LegacyMessageSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :content, :sender_id, :receiver_id
end
