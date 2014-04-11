# Schema Information
# Table name: rides
#  id                      :integer          not null, primary key
#  ride_id                 :integer
#  departure_place         :string
#  destination             :string
#  departure_time          :datetime
#  meeting_point           :string
#  free_seats              :string
#  department              :integer
#  realtime_km             :string
#  realtime_departure_time :datetime
#  realtime_arrival_time   :datetime
#  duration                :float
#  distance                :float
#  is_paid                 :boolean
#  is_finished             :boolean
#  contribution_mode       :integer          # for gamification
#  created_at              :datetime         not null
#  updated_at              :datetime         not null

class Ride < ActiveRecord::Base

  has_many :relationships, dependent: :delete_all
  has_many :passengers, -> { where(relationships: {is_driving: 'false'}) }, :through => :relationships, source: :user

  # todo: check if needed
  has_many :users, through: :relationships
  has_one :project
  has_many :requests

  before_save :default_values


  default_scope -> { order ('departure_time ASC') }
  validates :departure_place, :departure_time, :meeting_point, :free_seats, presence: true

  def driver # should return only one row
    result = self.relationships.find_by(ride_id: self.id, is_driving: true)
    unless result.nil?
      result = User.find_by(id: result[:user_id])
    end
    result
  end

  def assign_project(project)
    self.project = project
  end

  def default_values
    self.is_paid ||= false
    self.price ||= 0
    self.realtime_km ||= 0
    self.duration ||= 0
    self.contribution_mode ||= 0
    self.is_finished ||= false
    self.distance ||= 0
    nil
  end

  def request!(passenger, requested_from, request_to)
    self.requests.create!(passenger_id: passenger.id, requested_from: requested_from, request_to: request_to)
  end

  def pending_payments
    result = []
    self.relationships.where(is_driving: false).each do |r|
      if r.ride[:is_paid] == false
        payment = {}
        payment[:ride_id] = self.id
        payment[:driver_id] = r.ride.driver.id
        result.append(payment)
      end
    end
    result
  end

  def to_s
    "Ride id: #{self.id}, from: #{departure_place}, to: #{destination}"
  end

end

