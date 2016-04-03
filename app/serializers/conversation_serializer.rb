class ConversationSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :other_user_id, :ride

  has_many :messages

  def ride
    object.ride
  end

end
