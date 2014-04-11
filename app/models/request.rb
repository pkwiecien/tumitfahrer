# Schema Information
# Table name: requests
#  id                      :integer          not null, primary key
#  ride_id                 :integer
#  passenger_id            :integer
#  requested_from          :string
#  requested_to            :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null

class Request < ActiveRecord::Base
  belongs_to :ride
end
