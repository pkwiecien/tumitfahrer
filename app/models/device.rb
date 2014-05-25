# Schema Information
# Table name: devices
#  id                      :integer          not null, primary key
#  user_id                 :integer
#  token                   :string
#  platform                :string            # e.g ios, android, windows
#  enabled                 :boolean
#  created_at              :datetime         not null
#  updated_at              :datetime         not null

class Device < ActiveRecord::Base
  belongs_to :user
end
