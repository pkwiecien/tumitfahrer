class RideSerializer < ActiveModel::Serializer
  [:id, :departure_place, :destination, :meeting_point, :free_seats, :departure_time].each do |attr|
    # Tell serializer its an attribute
    attribute attr

    # Define a method with the same name as the attribute that calls the
    # underlying object and to_s on the result
    define_method attr do
      object.send(attr).to_s
    end
  end

end
