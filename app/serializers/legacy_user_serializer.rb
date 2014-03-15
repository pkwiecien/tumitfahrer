class LegacyUserSerializer < ActiveModel::Serializer
  [:id, :first_name, :last_name, :department, :car, :api_key, :phone_number, :ride_count, :exp, :ratings,
   :unbound_contributions, :rank, :email, :is_student].each do |attr|
    # Tell serializer its an attribute
    attribute attr

    # Define a method with the same name as the attribute that calls the
    # underlying object and to_s on the result
    define_method attr do
      object.send(attr).to_s
    end
  end

  def ride_count
    object.rides.count
  end

  def ratings
    ar = []
    ar.append(:star => object.ratings.all(conditions: ["rating_type = ?", 0]).count)
    ar.append(:positive => object.ratings.all(conditions: ["rating_type = ?", 1]).count)
    ar.append(:negative => object.ratings.all(conditions: ["rating_type = ?", 2]).count)
  end

end
