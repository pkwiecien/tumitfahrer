class RideSerializer < ActiveModel::Serializer
  attributes :id, :departure_place, :destination, :meeting_point, :free_seats, :departure_time,
   :price, :ride_owner, :is_ride_request, :requests, :passengers, :is_paid, :ride_type, :created_at,
      :updated_at

  def ride_owner
    object.ride_owner
  end

  def is_ride_request
    object.is_ride_request
  end

  def passengers
    object.passengers_of_ride
  end

  def requests
    object.requests
  end

end
