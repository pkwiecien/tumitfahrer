class Conversation < ActiveRecord::Base

  attr_accessor :current_page

  belongs_to :ride

  has_many :messages

  def create_message(content, sender_id, receiver_id)
    self.messages.create!(content: content, sender_id: sender_id,
                                    receiver_id: receiver_id)
    self.ride.update_attributes(updated_at: Time.zone.now)
  end

end
