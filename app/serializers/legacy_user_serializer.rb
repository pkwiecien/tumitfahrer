class LegacyUserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :department, :car, :api_key, :phone_number, :ride_count, :exp, :ratings,
   :unbound_contributions, :rank, :email, :is_student

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
