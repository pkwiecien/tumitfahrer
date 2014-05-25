# Schema Information
# Table name: friendship_reuqests
#  id                      :integer          not null, primary key
#  from_user_id            :integer
#  to_user_id              :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null

class FriendshipRequest < ActiveRecord::Base

  # Active Record relationships
  belongs_to :from_user, class_name: "User"
  belongs_to :to_user, class_name: "User"
end
