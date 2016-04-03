require 'digest/sha2'
require 'securerandom'

# Schema Information
# Table name: users
#  id                     :integer          not null, primary key
#  user_id                :integer
#  first_name             :string
#  last_name              :boolean          default(TRUE)
#  email                  :string
#  phone_number           :string
#  department             :string
#  car                    :string
#  password_digest        :string
#  remember_token         :string
#  is_admin               :boolean
#  is_student             :boolean
#  api_key                :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null

class User < ActiveRecord::Base

  # Active Record relationships
  has_many :relationships, foreign_key: :user_id
  has_many :rides
  has_many :devices
  has_many :ride_searches
  has_many :ratings, foreign_key: :from_user_id, class_name: "Rating"
  has_many :feedbacks

  # filters
  before_create :create_remember_token, :generate_api_key
  before_save { self.email = email.downcase }
  before_save :default_values

  # validators
  validates :first_name, presence: true, length: {minimum: 2, maximum: 20}
  validates :last_name, presence: true, length: {minimum: 2, maximum: 20}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}
  has_secure_password
  validates :password, length: {minimum: 6}

  # generate remember token used by web app to remember user session
  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def User.generate_api_key(user)
    user.update_attribute(:api_key, SecureRandom.urlsafe_base64)
  end

  def User.generate_new_password
    SecureRandom.hex(4)
  end

  def messages_send_to receiver_id, ride_id
    self.messages.where(receiver_id: receiver_id, ride_id:ride_id)
  end

  def messages_received_from sender_id, ride_id
    Message.where(receiver_id: self.id, sender_id: sender_id, ride_id: ride_id)
  end

  # each password stored in DB is encrypted with SHA512 and salt
  def User.generate_hashed_password(password)
    Digest::SHA512.hexdigest(password+Tumitfahrer::Application::SALT)
  end

  def send_message!(other_user, content)
    self.sent_messages.create!(sender_id: self.id, receiver_id: other_user.id, content: content)
  end

  def become_passenger!(new_ride_id)
    self.relationships.create!(ride_id: new_ride_id)
  end

  def request_ride!(ride, from, to)
    ride.requests.create!(ride_id: ride.id, passenger_id: self.id, requested_from: from, request_to: to)
  end

  def ratings_received
    Rating.where(to_user_id: self.id)
  end

  def give_rating_to_user user_id, ride_id, rating_type
    rating = self.ratings.create!(to_user_id: user_id, ride_id: ride_id, rating_type: rating_type)
    Ride.find_by(id: ride_id).update_attributes(updated_at: Time.zone.now)
    return rating
  end

  def register_device!(token, is_enabled, platform)
    self.devices.create!(token: token, enabled: is_enabled, platform: platform)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def rides_as_driver
    if self.rides.count > 0
      self.rides.joins(:relationships).where(relationships: {is_driving: true})
    else
      []
    end
  end

  # ride as passenger is when user is not owner of the ride and is not driving
  def rides_as_passenger
    ride_ids = self.relationships.select(:ride_id).where(is_driving: false).joins(:ride).where("rides.user_id <> ?", self.id)
    if ride_ids.count > 0
      Ride.where("id in (?)", ride_ids)
    else
      []
    end
  end

  # requests_for_driver is a ride, where user is owner of the ride, however he's not driving
  def requests_for_driver
    self.rides.joins(:relationships).where(relationships: {is_driving: false})
  end

  def all_rides
    rides_as_driver + requests_for_driver + rides_as_passenger + requested_rides
  end

  def requested_rides
    Ride.where(id: Request.where(passenger_id: self.id).select(:ride_id))
  end

  def compute_avg_rating
    positive = 0
    received_total = self.ratings_received.count

    if received_total < 1
      return -1
    end

    self.ratings_received.each do |rating|
      if rating.rating_type == 1
        positive+=1
      end
    end

    return positive/received_total
  end

  def to_s
    "#{self.first_name} #{self.last_name}, #{self.password_digest}"
  end

  private

  def create_remember_token
    self.remember_token = User.encrypt(User.new_remember_token)
  end

  def generate_api_key
    self.api_key = SecureRandom.urlsafe_base64
  end

  def default_values
    self.is_student ||= true
    self.rating_avg ||= -1.0
    nil
  end

end
