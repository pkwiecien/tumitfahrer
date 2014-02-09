class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :department, :car, :api_key
  has_many :rides

  def full_name
    "#{object.first_name} #{object.last_name}"
  end
end
