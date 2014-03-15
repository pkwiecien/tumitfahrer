class RideSerializer < ActiveModel::Serializer
  [:id, :departure_place, :destination, :meeting_point, :free_seats, :departure_time,
   :project_id, :price, :realtime_departure_time, :realtime_km, :driver_id].each do |attr|
    # Tell serializer its an attribute
    attribute attr

    # Define a method with the same name as the attribute that calls the
    # underlying object and to_s on the result
    define_method attr do
      object.send(attr).to_s
    end
  end


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
      ""
    end
  end

end
