class Ride < ActiveRecord::Base
  belongs_to :user, dependent: :destroy
  default_scope -> { order ('departure_time ASC') }
  validates :user_id, presence: true
  validates :departure_place, :departure_time, :meeting_point, :free_seats, presence: true

  def users
    Ride.all.each do |ride|

    end
  end
end

