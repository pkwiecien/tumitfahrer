class Ride < ActiveRecord::Base

  has_many :relationships, dependent: :delete_all
  has_many :passengers,  -> { where(relationships: {is_driving: 'false'})}, :through => :relationships, source: :user

  has_many :users, through: :relationships
  has_one :project
  has_many :requests

  before_save :default_values


  default_scope -> { order ('departure_time ASC') }
  validates :departure_place, :departure_time, :meeting_point, :free_seats, presence: true

  #def passengers(is_driver = false)
  #  results = []
  #  self.relationships.each do |r|
  #    if r[:is_driving] == is_driver
  #      results.append(r.user)
  #    end
  #  end
  #  results
  #end

  def driver # should return only one row
    result = passengers(true)
    unless result.nil?
      result.first
    end
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
    nil
  end

  def pending_payments
    result = []
    self.relationships.where(is_driving: false).each do |r|
      if r.ride[:is_paid] == false
        payment = {}
        payment[:ride_id] = self.id
        payment[:user_id] = r.user_id
        result.append(payment)
      end
    end
    result
  end


end

