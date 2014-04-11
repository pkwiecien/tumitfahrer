# Schema Information
# Table name: friendships
#  id                      :integer          not null, primary key
#  user_id                 :integer
#  friend_id               :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null

class Friendship < ActiveRecord::Base

  # Active Record relationships
  belongs_to :user, class_name: "User"
  belongs_to :friend, class_name: "User"
end
