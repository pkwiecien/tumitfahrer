class Project < ActiveRecord::Base
  belongs_to :ride
  has_many :contributions
  has_many :users, through: :contributions
end
