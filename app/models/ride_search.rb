# Schema Information
# Table name: ride_searches
#  id                      :integer          not null, primary key
#  user_id                 :integer
#  departure_place         :string
#  destination             :string
#  departure_time          :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null

class RideSearch < ActiveRecord::Base
  belongs_to :user
end
