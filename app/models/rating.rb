# Schema Information
# Table name: ratings
#  id                      :integer          not null, primary key
#  to_user_id              :integer
#  from_user_id            :integer
#  ride_id                 :integer
#  rating_type             :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null

class Rating < ActiveRecord::Base

  # Active Record relationships
  belongs_to :user
  belongs_to :from_user, class_name: "User"
  belongs_to :to_user, class_name: "User"

end
