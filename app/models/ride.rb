class Ride < ActiveRecord::Base
  belongs_to :user, dependent: :destroy
  default_scope -> { order ('departure_time ASC') }
  validates :user_id, presence: true
end

