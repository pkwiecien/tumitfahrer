# Schema Information
# Table name: relationships
#  id                      :integer          not null, primary key
#  user_id                 :integer
#  ride_is                 :integer
#  is_driving              :boolean         # TODO: check if necessary having driver_id
#  driver_ride_id          :integer         # TODO: potentially rename to simply driver_id
#  created_at              :datetime         not null
#  updated_at              :datetime         not null

class Relationship < ActiveRecord::Base
  belongs_to :user
  belongs_to :ride

  before_save :default_values

  def default_values
    self.is_driving ||= false
    nil # nil at the end is needed for a record to be saved, see: http://apidock.com/rails/ActiveRecord/RecordNotSaved
  end

end
