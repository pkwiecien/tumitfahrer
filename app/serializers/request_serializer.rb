class RequestSerializer < ActiveModel::Serializer
  attributes :id, :requested_from, :request_to, :passenger_id, :ride_id, :created_at, :updated_at

end
