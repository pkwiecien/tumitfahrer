class RideSerializer < ActiveModel::Serializer
  attributes :id, :departure_place, :destination, :meeting_point, :free_seats, :departure_time,
   :project_id, :price, :realtime_departure_time, :realtime_km, :driver_id, :requests, :passengers,
   :contribution_mode, :is_paid, :duration, :pending_payments

  def project_id
    unless object.project.nil?
      object.project.id
    else
      ""
    end
  end

  def driver_id
    unless object.driver.nil?
      object.driver.id
    else
      -1
    end
  end

  def pending_payments
    object.pending_payments
  end

  def passengers
    results = []
    object.passengers.each do |r|
      passenger = {}
      # todo: make sure if we need to include a param with user id
      passenger[:id] = r.id
      passenger[:realtime_km] = r.rides.find_by(id: object.id).realtime_km
      passenger[:departure_place] =  r.rides.find_by(id: object.id).departure_place
      passenger[:destination] = r.rides.find_by(id: object.id).destination
      passenger[:contribution_mode] = self.contribution_mode
      results.append(passenger)
    end
    results
  end

  def requests
    object.requests
  end


end
