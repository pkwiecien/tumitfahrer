class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :phone_number,
             :department, :car, :is_student, :api_key, :rating_average, :created_at, :updated_at

  def rating_average
    object.compute_avg_rating
  end

end
