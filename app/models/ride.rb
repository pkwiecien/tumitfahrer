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
#  ride_type               :integer          # 0 - campus ride, 1 - activity ride, 2 - ride request
#  created_at              :datetime         not null
#  updated_at              :datetime         not null

class Ride < ActiveRecord::Base

  # Active Record relationships
  has_many :relationships, dependent: :delete_all
  has_many :users, through: :relationships
  has_many :requests

  # filters
  before_save :default_values

  # validators
  validates :departure_place, :departure_time, presence: true

  # get a driver of a ride
  def driver # should return only one row
    result = self.relationships.find_by(ride_id: self.id, is_driving: true)
    unless result.nil?
      result = User.find_by(id: result[:user_id])
    end
    result
  end

  def request!(passenger, requested_from, request_to)
    self.requests.create!(passenger_id: passenger.id, requested_from: requested_from, request_to: request_to)
  end

  def passengers_of_ride
    relationships = Relationship.where(driver_ride_id: self.id, is_driving: false)
    results = []
    relationships.each do |r|
      user = User.find_by(id: r.user)
      results.append(user)
    end
    results
  end

  def self.rides_of_drivers
    rides = []
    #check if the driver for a ride is not null, if is null, then it's a passenger
    Ride.all.each do |ride|
      unless ride.driver.nil?
        rides.append(ride)
      end
    end
    return rides
  end

  def self.create_ride_by_owner ride_params, current_user
    is_driving =  ride_params[:is_driving].to_i
    ride_params.delete("is_driving")
    @ride = current_user.rides.create!(ride_params)
    if @ride.save
      @ride.relationships.create!(user: current_user, is_driving: is_driving)
      if @ride.save
        return @ride
      end
    end
    return nil
  end

  def to_s
    "Ride id: #{self.id}, from: #{departure_place}, to: #{destination}"
  end

  private

  def default_values
    self.is_paid ||= false
    self.price ||= 0
    self.realtime_km ||= 0
    self.duration ||= 0
    self.contribution_mode ||= 0
    self.is_finished ||= false
    self.distance ||= 0
    self.ride_type ||= 0
    nil
  end

end

