# Schema Information
# Table name: rides
#  id                      :integer          not null, primary key
#  ride_id                 :integer
#  departure_place         :string
#  destination             :string
#  departure_time          :datetime
#  meeting_point           :string
#  free_seats              :string
#  is_paid                 :boolean
#  price                   :float
#  is_finished             :boolean
#  ride_type               :integer          # 0 - campus ride, 1 - activity ride
#  created_at              :datetime         not null
#  updated_at              :datetime         not null

require 'geocoder'

class Ride < ActiveRecord::Base

  # Active Record relationships
  has_many :relationships, dependent: :delete_all
  has_many :users, through: :relationships
  has_many :requests
  has_many :conversations


  


  # filters
  before_save :default_values

  # validators
  validates :departure_place, :departure_time, :destination, presence: true

#after_validations :geocode

# get a driver of a ride
  def driver # should return only one row
    relationship = self.relationships.find_by(ride_id: self.id, is_driving: true)
    unless relationship.nil?
      relationship.user
    else
      nil
    end
  end

  def ride_owner
    User.find_by_id(self.user_id)
  end

  def is_ride_request
    ride_request_relationship = self.relationships.where("relationships.user_id = ? AND
relationships.is_driving= false", self.user_id)
    if ride_request_relationship.empty?
      return FALSE
    else
      return TRUE
    end

  end

  # get a passengers of a ride
  def passengers
    relationships = self.relationships.where("relationships.user_id <> ? AND relationships
.is_driving = false", self.user_id)
    return nil if relationships.nil? # no passengers

    passengers = []

    relationships.each do |r|
      passengers.append(r.user)
    end
    passengers
  end

  def self.create_ride_by_owner ride_params, current_user
    is_driving = ride_params[:is_driving].to_i
    ride_params.delete("is_driving")

    ride_params[:departure_latitude] = ride_params[:departure_latitude].to_f
    ride_params[:departure_longitude] = ride_params[:departure_longitude].to_f

    ride_params[:destination_latitude] = ride_params[:destination_latitude].to_f
    ride_params[:destination_longitude] = ride_params[:destination_longitude].to_f

    @ride = current_user.rides.create!(ride_params)
    if @ride.save
      @ride.relationships.create!(user: current_user, is_driving: is_driving)
      if @ride.save
        return @ride
      end
    end
    return nil
  end

  def create_ride_request passenger_id
    self.requests.create!(passenger_id: passenger_id)
  end

  def accept_ride_request driver_id, passenger_id, is_confirmed
    request = self.requests.where(passenger_id: passenger_id).first
    if request != nil
      if is_confirmed.to_i == 0
        request.destroy
      else
        relationship = self.relationships.create(user_id: passenger_id)
        if relationship.save
          self.create_conversation driver_id, passenger_id
          request.destroy
        end
      end
    end
  end

  def remove_ride_request request_id
    request = self.requests.find_by(id: request_id)
    if request != nil
      request.destroy
    end
  end

  def remove_passenger driver_id, passenger_id
    relationships = self.relationships.where("relationships.user_id <> ? AND relationships
.is_driving = false", driver_id)

    passenger = relationships.where("user_id = ? AND is_driving = false", passenger_id).first
    if passenger != nil
      passenger.destroy
    end

  end

  def self.rides_nearby departure_place, departure_threshold, destination, destination_threshold, departure_time

    request_departure_coordinates = Geocoder.coordinates(departure_place)
    request_destination_coordinates = Geocoder.coordinates(destination)

    rides = []
    Ride.where("departure_time > ?", Time.now).each do |ride|
      db_coordinates = [ride.departure_latitude, ride.destination_longitude]
      departure_distance = Geocoder::Calculations.distance_between(db_coordinates, request_departure_coordinates)

      db_coordinates = [ride.destination_latitude, ride.destination_longitude]
      destination_distance = Geocoder::Calculations.distance_between(db_coordinates, request_destination_coordinates)

      if departure_distance <= departure_threshold && destination_distance <= destination_threshold
        if departure_time.nil? || departure_time.empty? # no date specified, return all rides that match criteria
          rides.append(ride)
        elsif departure_time < Date.tomorrow && departure_time > Date.yesterday # otherwise the day should match
          rides.append(ride)
        end
      end
    end

    return rides
  end

  def create_conversation user_id, other_user_id
    self.conversations.create!(user_id: user_id, other_user_id: other_user_id)
  end

  def conversation_exists? user_id, other_user_id
    if self.conversations.where(user_id: user_id, other_user_id: other_user_id) || self
    .conversations.where(user_id: other_user_id, other_user_id: user_id)
      return TRUE
    else
      return FALSE
    end
  end

  def to_s
    "Ride id: #{self.id}, from: #{departure_place}, to: #{destination}"
  end

  private

  def default_values
   
    self.price ||= 0
    self.ride_type ||= 0
    nil
  end

end

