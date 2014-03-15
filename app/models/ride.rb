class Ride < ActiveRecord::Base
  has_many :relationships
  has_many :users, through: :relationships
  has_one :project

  default_scope -> { order ('departure_time ASC') }
  validates :departure_place, :departure_time, :meeting_point, :free_seats, presence: true

  def passengers(is_driver = false)
    results = []
    self.relationships.each do |r|
      if r[:is_driving] == is_driver
        results.append(r.user)
      end
    end
    results
  end

  def driver # should return only one row
    result = passengers(true)
    unless result.nil?
      result.first
    end
  end

end

