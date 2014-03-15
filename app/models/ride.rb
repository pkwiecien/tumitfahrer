class Ride < ActiveRecord::Base
  has_many :relationships
  has_many :users, through: :relationships

  default_scope -> { order ('departure_time ASC') }
  validates :departure_place, :departure_time, :meeting_point, :free_seats, presence: true

  def users
    Ride.all.each do |ride|

    end
  end
end

