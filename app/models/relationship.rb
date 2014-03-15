class Relationship < ActiveRecord::Base
  belongs_to :user
  belongs_to :ride

  before_save :default_values

  def default_values
    self.is_driving ||= false
    nil # nil at the end is needed for a record to be saved, see: http://apidock.com/rails/ActiveRecord/RecordNotSaved
  end

end
