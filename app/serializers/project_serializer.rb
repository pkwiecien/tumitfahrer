class ProjectSerializer < ActiveModel::Serializer
  [:id, :fundings_target, :phase, :title, :owner_id, :description,
   :date, :ride_id, :contributions].each do |attr|
    # Tell serializer its an attribute
    attribute attr

    # Define a method with the same name as the attribute that calls the
    # underlying object and to_s on the result
    define_method attr do
      object.send(attr).to_s
    end
  end

  def contributions
    object.contributions
  end


end
