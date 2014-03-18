class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :fundings_target, :phase, :title, :owner_id, :description,
   :date, :ride_id, :contributions

  def contributions
    object.contributions
  end


end
