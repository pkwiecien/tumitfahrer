class Conversation < ActiveRecord::Base

  attr_accessor :current_page

  belongs_to :ride

  has_many :messages

  def create_message(content, sender_id, receiver_id)
    message = self.messages.create!(content: content, sender_id: sender_id,
                                    receiver_id: receiver_id)
    self.ride.update_attributes(updated_at: Time.zone.now)
    return message
  end


  def last_message_time
    if self.messages.count > 0
      self.messages.last.created_at
    else
      nil
    end
  end

  def last_sender_id
    if self.messages.count > 0
      self.messages.last.sender_id
    else
      nil
    end
  end

end
