# Schema Information
# Table name: payments
#  id                      :integer          not null, primary key
#  from_user_id            :integer
#  to_user_id              :integer
#  ride_id                 :integer
#  amount                  :float
#  created_at              :datetime         not null
#  updated_at              :datetime         not null

class Payment < ActiveRecord::Base

  # Active Record relationships
  belongs_to :user
  belongs_to :from_user, class_name: "User"
  belongs_to :to_user, class_name: "User"

end
