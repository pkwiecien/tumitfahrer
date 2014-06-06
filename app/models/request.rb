# Schema Information
# Table name: requests
#  id                      :integer          not null, primary key
#  ride_id                 :integer
#  passenger_id            :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null

class Request < ActiveRecord::Base
  # Active Record relationships
  belongs_to :ride
end
