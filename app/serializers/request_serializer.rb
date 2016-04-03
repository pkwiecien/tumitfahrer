class RequestSerializer < ActiveModel::Serializer
  attributes :id, :passenger_id, :ride, :created_at, :updated_at

end
