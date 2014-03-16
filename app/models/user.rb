require 'digest/sha2'
class User < ActiveRecord::Base

  has_many :relationships, foreign_key: :user_id
  has_many :rides, through: :relationships

  has_many :ratings
  has_many :contributions
  has_many :projects, through: :contributions

  has_many :friendships
  has_many :friend_requests, foreign_key: :to_user_id
  has_many :pending_friend_requests, foreign_key: :from_user_id, class_name: "FriendRequest"

  before_create :create_remember_token, :generate_api_key
  before_save { self.email = email.downcase }
  before_save :default_values

  validates :first_name, presence: true, length: {minimum: 2, maximum: 20}
  validates :last_name, presence: true, length: {minimum: 2, maximum: 20}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}
  has_secure_password
  validates :password, length: {minimum: 6}

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def User.generate_api_key(user)
    user.update_attribute(:api_key, SecureRandom.urlsafe_base64)
  end

  def to_s
    "#{self.first_name} #{self.last_name}, #{self.password_digest}"
  end

  def become_passenger!(new_ride_id)
    self.relationships.create!(ride_id: new_ride_id)
  end

  def rides_as_passenger
    result = []
    self.relationships.where(is_driving: false).to_a.each do |rel|
      result.append(rel.ride)
    end
    result
  end

  def rides_as_driver
    result = []
    self.relationships.where(is_driving: true).to_a.each do |rel|
      result.append(rel.ride)
    end
    result
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

  def friends
    result = []
    self.friendships.each do |f|
      result.append(f.friend)
    end
    result
  end

  def send_friend_request!(to_user)
    self.pending_friend_requests.create!(to_user_id: to_user.id, from_user_id: self.id)
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
    nil
  end


end
