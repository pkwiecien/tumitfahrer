# Used by API v1 and adapted to existing Android app
# As soon as the Android App is updated, message_serializer should be used
class LegacyMessageSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :content, :sender_id, :receiver_id
end
