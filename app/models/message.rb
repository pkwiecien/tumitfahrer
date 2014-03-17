class Message < ActiveRecord::Base
  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"

  before_save :default_values

  def default_values
    self.is_seen ||= false
    nil
  end
end
