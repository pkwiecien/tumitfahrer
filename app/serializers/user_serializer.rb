class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :phone_number,
             :department, :car, :is_student, :api_key, :created_at, :updated_at

end
