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
#  department             :integer
#  car                    :string
#  password_digest        :string
#  remember_token         :string
#  is_admin               :boolean
#  is_student             :boolean
#  api_key                :string
#  rank                   :integer
#  unbound_contributions  :integer
#  exp                    :float
#  gamification           :boolean
#  created_at             :datetime         not null
#  updated_at             :datetime         not null

class User < ActiveRecord::Base

  # Active Record relationships
  has_many :relationships, foreign_key: :user_id
  has_many :rides, through: :relationships, source: :ride, class_name: "Ride", dependent: :delete_all
  has_many :rides_as_driver, -> { where(relationships: {is_driving: 'true'})},
           through: :relationships, source: :ride, dependent: :delete_all
  has_many :rides_as_passenger, -> { where(relationships: {is_driving: 'false'})},
           through: :relationships, source: :ride

  has_many :ratings_given, foreign_key: :from_user_id, class_name: "Rating"
  has_many :ratings_received, foreign_key: :to_user_id, class_name: "Rating"

  has_many :payments_given, foreign_key: :from_user_id, class_name: "Payment"
  has_many :payments_received, foreign_key: :to_user_id, class_name: "Payment"

  has_many :contributions
  has_many :offered_projects, foreign_key: :owner_id, class_name: "Project", source: :project
  has_many :contributed_projects, through: :contributions, class_name: "Project", source: :project

  has_many :friendships
  has_many :friends, through: :friendships, source: :friend

  has_many :friendship_requests, foreign_key: :from_user_id
  has_many :sent_friendship_requests, foreign_key: :from_user_id, class_name: "FriendshipRequest" # requests received by this user from other users
  has_many :pending_friends, through: :friendship_requests, source: :to_user, class_name: "User"

  has_many :reverse_friendship_requests, foreign_key: :to_user_id, class_name: "FriendshipRequest"
  has_many :received_friendship_requests, foreign_key: :to_user_id, class_name: "FriendshipRequest" #this user sends a request to another user
  has_many :requesting_friends, through: :reverse_friendship_requests, source: :from_user, class_name: "User"

  has_many :messages
  has_many :sent_messages, foreign_key: :sender_id, class_name: "Message"
  has_many :received_messages, foreign_key: :receiver_id, class_name: "Message"

  has_many :devices
  has_many :ride_searches

  # TODO: avatars
  ## https://github.com/thoughtbot/paperclip
  #has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  #validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

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

  def friend?(other_user)
    friendships.find_by(friend_id: other_user.id)
  end

  def befriend!(other_user)
    friendships.create!(friend_id: other_user.id)
  end

  def unfriend!(other_user)
    friendships.find_by(friend_id: other_user.id).destroy
  end

  def send_friend_request!(to_user)
    self.sent_friendship_requests.create!(to_user_id: to_user.id, from_user_id: self.id)
  end

  def handle_friend_request(other_user, shouldAccept)
    logger.debug "Accepting friendship from #{self.id} to other user: #{other_user.id}"
    if shouldAccept == true
      self.befriend!(other_user)
    end
    friendship = FriendshipRequest.find_by(from_user_id: other_user.id, to_user_id: self.id)
    unless friendship.nil?
      friendship.destroy
    end
  end

  def pending_payments
    self.rides_as_passenger.where(is_paid: false)
  end

  def new_project()
    Project.create(owner_id: self.id, )
  end

  def request_ride!(ride, from, to)
    ride.requests.create!(ride_id: ride.id, passenger_id: self.id, requested_from: from, request_to: to)
  end

  def register_device!(token, is_enabled, platform)
    self.devices.create!(token: token, enabled: is_enabled, platform: platform)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def to_s
    "#{self.first_name} #{self.last_name}, #{self.password_digest}"
  end

  def compute_avg_rating
    num_all_rating = self.ratings_received.count
    if num_all_rating == 0
      0
    else
      self.ratings_received.where('rating_type=?', 1)/num_all_rating
    end
  end

  private

  def create_remember_token
    self.remember_token = User.encrypt(User.new_remember_token)
  end

  def generate_api_key
    self.api_key = SecureRandom.urlsafe_base64
  end

  def default_values
    self.rank ||= 0
    self.exp ||= 0
    self.unbound_contributions ||= 0
    self.gamification ||= true
    self.is_student ||= true
    self.rating_avg ||= 0.0
    nil
  end


end
