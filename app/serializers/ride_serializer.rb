class RideSerializer < ActiveModel::Serializer
  attributes :id, :departure_place, :destination, :meeting_point, :free_seats, :departure_time,
   :price, :ride_owner, :is_ride_request, :requests, :passengers, :conversations, :ratings, :is_paid,
   :ride_type, :car, :last_cancel_time, :created_at, :updated_at

  has_many :conversations, serializer: SimpleConversationSerializer

  def ride_owner
    object.ride_owner
  end

  def is_ride_request
    object.is_ride_request
  end

  def passengers
    object.passengers
  end

  def requests
    object.requests
  end

end
