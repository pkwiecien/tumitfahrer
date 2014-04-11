# Schema Information
# Table name: projects
#  id                      :integer          not null, primary key
#  fundings_target         :integer
#  phase                   :integer
#  owner_id                :integer
#  description             :string
#  title                   :string
#  date                    :datetime
#  ride_id                 :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null

class Project < ActiveRecord::Base
  belongs_to :ride
  belongs_to :user
  has_many :contributions
  has_many :users, through: :contributions

  before_save :default_values

  def default_values
    self.fundings_target ||= 0
    self.phase ||= 0
    nil
  end
end
