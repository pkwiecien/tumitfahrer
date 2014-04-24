class RideSerializer < ActiveModel::Serializer
  attributes :id, :departure_place, :destination, :meeting_point, :free_seats, :departure_time,
   :project_id, :price, :realtime_departure_time, :realtime_km, :driver, :requests, :passengers,
   :contribution_mode, :is_paid, :duration, :pending_payments, :distance, :created_at, :updated_at

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
    relationships = Relationship.where(driver_ride_id: object.id, is_driving: false)
    results = []
    relationships.each do |r|
      ride = Ride.find_by(id: r.ride_id)
      passenger = {}
      passenger[:id] = r.user_id
      passenger[:realtime_km] = ride.realtime_km
      passenger[:departure_place] =  ride.departure_place
      passenger[:destination] = ride.destination
      passenger[:contribution_mode] = ride.contribution_mode
      results.append(passenger)
    end
    results
  end

  def requests
    object.requests
  end


end
