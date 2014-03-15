class LegacyUserSerializer < ActiveModel::Serializer
  [:id, :first_name, :last_name, :department, :car, :api_key, :phone_number, :ride_count, :exp, :rating_computed,
   :unbound_contributions, :rank].each do |attr|
    # Tell serializer its an attribute
    attribute attr

    # Define a method with the same name as the attribute that calls the
    # underlying object and to_s on the result
    define_method attr do
      object.send(attr).to_s
    end
  end
  #has_many :ratings

  def full_name
    "#{object.first_name} #{object.last_name}"
  end

  def ride_count
    object.rides.count
  end

  def rating_computed
    ar = []
    ar.append(:star => object.ratings.all(conditions: ["rating_type = ?", 0]).count)
    ar.append(:positive => object.ratings.all(conditions: ["rating_type = ?", 1]).count)
    ar.append(:negative => object.ratings.all(conditions: ["rating_type = ?", 2]).count)
  end

end
