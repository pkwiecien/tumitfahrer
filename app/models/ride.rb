class Ride < ActiveRecord::Base

  has_many :relationships, dependent: :delete_all
  has_many :passengers, -> { where(relationships: {is_driving: 'false'}) }, :through => :relationships, source: :user

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
    nil
  end

  def pending_payments
    result = []
    self.relationships.where(is_driving: false).each do |r|
      if r.ride[:is_paid] == false
        payment = {}
        payment[:ride_id] = self.id
        payment[:driver_id] = r[:driver_id]
        result.append(payment)
      end
    end
    result
  end


end

