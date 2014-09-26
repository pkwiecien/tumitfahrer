require 'gcm'
require "uri"
require "net/http"

#class to send messages. Cron job will call this class.
class MessageSender

  #This function is called by Cron job to fetch the next batch of notifications to send. After fetching it sends the messages to different platforms
  def self.send_next_batch
   notification_list = Notification.get_notification_list
   send_message(notification_list)
  end

  def self.send_single_message(notification)
    notification_list = Notification.get_single_notification_data(notification)
    send_message(notification_list)
  end

  #Method to send messages to different platforms based on the platform information in the object.``
  def self.send_message(notificationDataList)
    notificationDataList.each do |notification|
      begin
        if(notification.device_type == 'Android')
          result = MessageSender.send_android_notification(notification.device_id, notification.message)
          if (result == 1)
            #Update the database
            Notification.update_status(notification.notification_id, notification.message)
          end
        elsif(notification.device_type == 'iPhone')
                MessageSender.send_iphone_notification(notification.device_id, notification.message) #TODO: Check message succesfully sent
                Notification.update_status(notification.notification_id, notification.message)
        elsif(notification.device_type == 'VisioM')
               #Send a post request to the VisioM server. Url is of the format 'http://thewebsite.net'
               #device_id should be the URL of the car
            MessageSender.send_visiom_notification(notification.device_id, notification.message)
            Notification.update_status(notification.notification_id, notification.message)
        end
      rescue
        puts("ERROR: While sending push notification: "+notification.notification_id)
      end
    end
  end

  #This function sends push notificaiton to android devices. It takes the token of android device and notification message as output.
  def self.send_android_notification(token, message)
    gcm = GCM.new('AIzaSyDNjxSCSc_zRBlC8jHpqxWgP1crx41B0IA') #TODO Initialize it only one time at app start
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
    if(  JSON.parse(response[:body])["success"] == 1 )
      return 1
    else
      #TODO: Handle what to do if the messsage is not sent/ Log it and retur 1
      puts("ERROR: While sending android push notification"+response)
      return 1
    end
  end

  #This function sends push notificaiton to iPhone devices. It takes the token of android device and notification message as output.
  def self.send_iphone_notification(token,message)
    pusher = Grocer.pusher(certificate: Rails.root + "/config/certificate/cert_apple_development.pem", passphrase: "", gateway: "gateway.sandbox.push.apple.com", port: 2195, retries: 3)

    #working device id pawel: f4f382b537d663af6256649e412fc19110cbbdc3d80c04373c090a623810127e
    #260359d0e9baf2ed4065c9876c985c8e636ee8c8
    #Michel: 7dea4155e62e5a4bddc1fe62fb0ad28ab90f0d36d05313ebed626b42e4019c3e
    notification = Grocer::Notification.new(device_token:token, alert: message, badge: 42, content_available: true, sound: "siren.aiff", expiry: Time.now + 60*60, identifier: 1234)

    response = pusher.push(notification)
    if(response < 11 && response > 0) #TODO: Handle response
      puts("ERROR: While sending iOS push notification"+response)
    end
  end

  #Thsi function sends a POST request to the URL of the car. Car fetches the message from the POST request and puts it on the bus
  def self.send_visiom_notification(url,message)
    response = Net::HTTP.post_form(URI.parse(url), {'notification'=>message})
    #response.code #TODO: Add check if required based on the code
    #puts response.body
  end
end