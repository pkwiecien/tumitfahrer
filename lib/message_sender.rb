require 'gcm'

#class to send messages. Cron job will call this class.
class MessageSender

  def self.send_next_batch
   notification_list = Notification.get_notification_list
   send_message(notification_list)
  end

  #Method to send messages to different platforms based on the platform information in the object.``
  def self.send_message(notificationDataList)
    notificationDataList.each do |notification|

      if(notification.device_type == 'Android')
        result = MessageSender.send_android_notification(notification.device_id, notification.message)
        if (result == 1)
          #Update the database
          Notification.update_status(notification.notification_id, true)
        end
      else if(notification.device_type == 'iPhone')
          MessageSender.send_iphone_notification(notification.device_id, notification.message)
          Notification.update_status(notification.notification_id, true)

      #TODO: Add check for visiom
      end
    end
  end

  end

  def self.send_android_notification(token, message)
    gcm = GCM.new('AIzaSyDNjxSCSc_zRBlC8jHpqxWgP1crx41B0IA')
    registration_id = [token]
    options = {
        'data' => {
            'message' => message
        },
        'collapse_key' => 'updated_state'
    }
    #http = Net::HTTP.new("www.google.com/", 80)
    #http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    #http.get("www.google.com/");
    response = gcm.send_notification(registration_id, options)
    if( response.success == 1)
      return 1
    else
      #TODO: Handle what to do if the messsage is not sent
    end
  end

  def self.send_iphone_notification(token,message)
    pusher = Grocer.pusher(certificate: Rails.root + "/config/certificate/cert_apple_development.pem", passphrase: "", gateway: "gateway.sandbox.push.apple.com", port: 2195, retries: 3)

    #working device id pawel: f4f382b537d663af6256649e412fc19110cbbdc3d80c04373c090a623810127e
    #260359d0e9baf2ed4065c9876c985c8e636ee8c8
    #Michel: 7dea4155e62e5a4bddc1fe62fb0ad28ab90f0d36d05313ebed626b42e4019c3e
    notification = Grocer::Notification.new(device_token:token, alert: message, badge: 42, content_available: true, sound: "siren.aiff", expiry: Time.now + 60*60, identifier: 1234)

    response = pusher.push(notification)
    #TODO: handle the response
  end

end