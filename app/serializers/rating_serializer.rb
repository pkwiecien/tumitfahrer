class RatingSerializer < ActiveModel::Serializer
  attributes :rating_type, :from_user_id, :to_user_id, :ride_id, :created_at, :updated_at

end
