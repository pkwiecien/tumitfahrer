class Project < ActiveRecord::Base
  belongs_to :ride
  has_many :contributions
  has_many :users, through: :contributions

  before_save :default_values

  def default_values
    self.fundings_target ||= 0
    self.phase ||= 0
    nil
  end
end
