class Contribution < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  before_save :default_values

  def default_values
    self.amount ||= 0
    nil
  end
end
