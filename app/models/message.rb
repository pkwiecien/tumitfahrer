# Schema Information
# Table name: messages
#  id                      :integer          not null, primary key
#  sender_id               :integer
#  content                 :string
#  is_seen                 :boolean
#  created_at              :datetime         not null
#  updated_at              :datetime         not null

class Message < ActiveRecord::Base

  # Active Record relationships
  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"

  # filters
  before_save :default_values

  def to_s
    "Message (id: #{id}), content: #{content}"
  end

  private

  def default_values
    self.is_seen ||= false
    nil
  end
end
