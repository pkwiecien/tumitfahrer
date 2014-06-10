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

class Ride < ActiveRecord::Base

  # Active Record relationships

  #Added by Behroz
  has_many :notifications

  has_many :relationships, dependent: :delete_all
  has_many :users, through: :relationships
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
    ride_request_relationship = self.relationships.where("relationships.user_id = ? AND relationships.is_driving= 'f'", self.user_id)
    if ride_request_relationship.empty?
      return FALSE
    else
      return TRUE
    end

  end

  # get a passengers of a ride
  def passengers
    relationships = self.relationships.where("relationships.user_id <> ? AND relationships.is_driving = 'f'", self.user_id)
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
    @ride = current_user.rides.create!(ride_params)
    if @ride.save
      @ride.relationships.create!(user: current_user, is_driving: is_driving)
      if @ride.save
        return @ride
      end
    end

    #Added by Behroz - Insert data in notification table - Start - 10-June-2014
    Notification.insert_notification(current_user.id ,@ride.id,1,@ride.departure_time,'f')
    #Added by Behroz - Insert data in notification table - End - 10-June-2014

    return nil
  end

  def create_ride_request passenger_id
    self.requests.create!(passenger_id: passenger_id)
  end

  def accept_ride_request passenger_id
    request = self.requests.where(passenger_id: passenger_id).first
    if request != nil
      relationship = self.relationships.create(user_id: user_id)
      if relationship.save
        request.destroy
      end
    end
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
    self.is_paid ||= false
    self.price ||= 0
    self.ride_type ||= 0
    nil
  end

end

