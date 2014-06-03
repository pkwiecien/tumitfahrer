class RideSerializer < ActiveModel::Serializer
  attributes :id, :departure_place, :destination, :meeting_point, :free_seats, :departure_time,
   :price, :driver, :requests, :passengers, :is_paid, :ride_type, :created_at, :updated_at

  def driver
    unless object.driver.nil?
      object.driver
    else
      nil
    end
  end

  def passengers
    object.passengers_of_ride
  end

  def requests
    object.requests
  end


end
