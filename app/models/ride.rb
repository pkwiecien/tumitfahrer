# Schema Information
# Table name: rides
#  id                      :integer          not null, primary key
#  ride_id                 :integer
#  departure_place         :string
#  destination             :string
#  departure_time          :datetime
#  meeting_point           :string
#  free_seats              :integer
#  is_paid                 :boolean
#  price                   :float
#  is_finished             :boolean
#  ride_type               :integer          # 0 - campus ride, 1 - activity ride
#  created_at              :datetime         not null
#  updated_at              :datetime         not null

require 'geocoder'

class Ride < ActiveRecord::Base

  # Active Record relationships

  #Added by Behroz
  has_many :notifications

  has_many :relationships, dependent: :delete_all
  has_many :users
  has_many :requests
  has_many :conversations

  # filters
  before_save :default_values

  # validators
  validates :departure_place, :departure_time, :destination, presence: true

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
    ride_request_relationship = self.relationships.where("relationships.user_id = ? AND relationships.is_driving= false", self.user_id)
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

  def self.create_regular_rides regular_ride_dates, ride_params, current_user
    ride_params.delete("repeat_dates")
    @rides = []
    regular_ride_dates.each do |ride_date|
      ride_params[:departure_time] = ride_date
      @ride = Ride.create_ride_by_owner ride_params, current_user, true
      @rides.append(@ride)
      @ride.update_attributes!(regular_ride_id: @rides.first.id)
    end
    return @rides
  end

  def self.create_ride_by_owner ride_params, current_user, is_driving
    ride_params.delete("is_driving")

    ride_params[:departure_latitude] = ride_params[:departure_latitude].to_f
    ride_params[:departure_longitude] = ride_params[:departure_longitude].to_f

    ride_params[:destination_latitude] = ride_params[:destination_latitude].to_f
    ride_params[:destination_longitude] = ride_params[:destination_longitude].to_f

    @ride = current_user.rides.create!(ride_params)
    if @ride.save
      @ride.update_attributes!(user_id: current_user.id)
      @ride.relationships.create!(user: current_user, is_driving: is_driving)
      if @ride.save

        #Added by Behroz - Insert data in notification table - Start - 10-June-2014
        Notification.driver_pickup(current_user.id, @ride.id, @ride.departure_time)
        #Added by Behroz - Insert data in notification table - End - 10-June-2014

        return @ride
      end
    end
    return nil
  end

  def create_ride_request passenger_id
    request = self.requests.create!(passenger_id: passenger_id)
    # self.create_conversation self.ride_owner.id, passenger_id
    self.update_attributes(updated_at: Time.zone.now)
    return request
  end

  def accept_ride_request driver_id, passenger_id, is_confirmed
    request = self.requests.where(passenger_id: passenger_id).first
    if request != nil
      if is_confirmed.to_i == 0
        request.destroy
      else
        relationship = self.add_passenger passenger_id
        if !relationship.nil?
          request.destroy
        end
      end
    end
  end

  def add_passenger passenger_id
    if self.relationships.find_by(user_id: passenger_id, is_driving: false).nil?
      relationship = self.relationships.create(user_id: passenger_id)
      if relationship.save
        self.update_attributes(updated_at: Time.zone.now)
        if !self.conversation_exists? self.ride_owner.id, passenger_id
          self.create_conversation self.ride_owner.id, passenger_id
        end
      end
    else
      return nil
    end
  end

  def remove_ride_request request_id
    request = self.requests.find_by(id: request_id)
    if request != nil
      self.update_attributes(updated_at: Time.zone.now)
      request.destroy
    end
  end

  def remove_passenger driver_id, passenger_id
    relationships = self.relationships.where("relationships.user_id <> ? AND relationships
.is_driving = false", driver_id)

    passenger = relationships.where("user_id = ? AND is_driving = false", passenger_id).first
    if passenger != nil

      #Changed by Behroz - 27 June-2014 - Start
      #Since, we are deleting the passenger from the passenger list. We need to inform the driver that passenger has left the ride
      notifications.reservation_cancelled(driver_id,passenger_id, self.id )
      #Changed by Behroz - 27 June-2014 - End

      passenger.destroy
      self.remove_conversation_between_users driver_id, passenger_id
      self.update_attributes(updated_at: Time.zone.now, last_cancel_time: Time.zone.now)
    end
  end

  def self.rides_nearby departure_place, departure_threshold, destination, destination_threshold, departure_time, ride_type

    request_departure_coordinates = Geocoder.coordinates(departure_place)
    request_destination_coordinates = Geocoder.coordinates(destination)

    rides = []
    Ride.where("departure_time > ? AND ride_type = ?", Time.zone.now, ride_type).each do |ride|
      if ride.departure_latitude == 0
        db_coordinates = Geocoder.coordinates(ride.departure_place)
        Ride.find_by_id(ride.id).update_attributes!(departure_latitude: db_coordinates[0], departure_longitude: db_coordinates[1])
      else
        db_coordinates = [ride.departure_latitude, ride.departure_longitude]
      end

      departure_distance = Geocoder::Calculations.distance_between(db_coordinates, request_departure_coordinates)

      if ride.destination_latitude == 0
        db_coordinates = Geocoder.coordinates(ride.destination)
        Ride.find_by_id(ride.id).update_attributes!(destination_latitude: db_coordinates[0], destination_longitude: db_coordinates[1])
      else
        db_coordinates = [ride.destination_latitude, ride.destination_longitude]
      end
      destination_distance = Geocoder::Calculations.distance_between(db_coordinates, request_destination_coordinates)

      if departure_place.empty? && destination.empty?
        #continue
      elsif (departure_place.empty? || (!departure_place.empty? && departure_distance <= departure_threshold)) &&
          (destination.empty? || (!destination.empty? && destination_distance <= destination_threshold))
        logger.debug "#{ride.departure_time.tomorrow} and #{ride.departure_time.yesterday}"
        if departure_time.nil? # no date specified, return all rides that match criteria
          rides.append(ride)
        elsif departure_time.day == ride.departure_time.day  && \
         departure_time.month == ride.departure_time.month &&  \
         departure_time.year == ride.departure_time.year # otherwise the day should match
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
    if self.conversations.where(user_id: user_id, other_user_id: other_user_id).count == 0 && self
    .conversations.where(user_id: other_user_id, other_user_id: user_id).count == 0
      return FALSE
    else
      return TRUE
    end
  end

  def remove_conversation_between_users user_id, other_user_id
    conversation = self.conversations.where(user_id: user_id, other_user_id: other_user_id)
    if conversation.nil?
      conversation = self.conversations.where(user_id: other_user_id, other_user_id: user_id)
    end

    if !conversation.first.nil?
      conversation.first.destroy
    end
  end

  def ratings
    Rating.where(ride_id: self.id)
  end

  def to_s
    "Ride id: #{self.id}, from: #{departure_place}, to: #{destination}"
  end

  private

  def default_values
    self.price ||= 0
    self.ride_type ||= 0
    self.car ||= ""
    nil
  end

end

