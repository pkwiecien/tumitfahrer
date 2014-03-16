class UserSerializer < ActiveModel::Serializer
  [:id, :first_name, :last_name, :department, :car, :api_key].each do |attr|
    # Tell serializer its an attribute
    attribute attr

    # Define a method with the same name as the attribute that calls the
    # underlying object and to_s on the result
    define_method attr do
      object.send(attr).to_s
    end
  end

  def full_name
    "#{object.first_name} #{object.last_name}"
  end
end
