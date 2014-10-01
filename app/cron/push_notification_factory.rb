require 'message_sender'
class PushNotificationFactory
  def self.pushNotificationBot
    puts "cronjobs is called in every minutes from tumitfahrer"
    MessageSender.send_next_batch
  end

end