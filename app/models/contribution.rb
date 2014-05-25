# Schema Information          # used for gamification
# Table name: contributions
#  id                      :integer          not null, primary key
#  user_id                 :integer
#  project_id              :integer
#  amount                  :float
#  created_at              :datetime         not null
#  updated_at              :datetime         not null

class Contribution < ActiveRecord::Base
  # Active Record relationships
  belongs_to :user
  belongs_to :project

  # filters
  before_save :default_values

  private

  def default_values
    self.amount ||= 0
    nil
  end
end
