class RideSerializer < ActiveModel::Serializer
  attributes :id, :departure_place, :destination, :meeting_point, :free_seats, :departure_time,
   :price, :realtime_departure_time, :realtime_km, :driver, :requests, :passengers,
   :contribution_mode, :is_paid, :duration, :pending_payments, :distance, :ride_type, :ride_owner_id,
   :created_at, :updated_at

  def project_id
    unless object.project.nil?
      object.project.id
    else
      ""
    end
  end

  def driver
    unless object.driver.nil?
      object.driver
    else
      nil
    end
  end

  def pending_payments
    object.pending_payments
  end

  def passengers
    object.passengers_of_ride
  end

  def requests
    object.requests
  end


end
