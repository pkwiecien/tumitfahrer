# Used by API v1 and adapted to existing Android app
# As soon as the Android App is updated, user_serializer should be used
class LegacyUserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :department, :car, :api_key, :phone_number, :ride_count, :exp, :ratings,
   :unbound_contributions, :rank, :email, :is_student, :gamification

  def ride_count
    object.rides.count
  end

  def ratings
    ar = []
    ratings = object.ratings_received + object.ratings_given
    ar.append(:star => ratings.select{|rating_type| rating_type == 0}.size)
    ar.append(:positive => ratings.select{|rating_type| rating_type == 1}.size)
    ar.append(:negative => ratings.select{|rating_type| rating_type == 2}.size)
  end

end
