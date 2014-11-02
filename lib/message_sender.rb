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

    puts("Total notifications => " + notificationDataList.count.to_s)
    notificationDataList.each do |notification|
      begin
        if(notification.device_type.downcase == 'android')
          result = MessageSender.send_android_notification(notification.device_id, notification.message)

	  #puts "Sending Android Push Notification " + result

          if (result == 1)
            #Update the database
            Notification.update_status(notification.notification_id, notification.message)
          end
        elsif(notification.device_type.downcase == 'ios')
                MessageSender.send_iphone_notification(notification.device_id, notification.message) #TODO: Check message succesfully sent
                Notification.update_status(notification.notification_id, notification.message)
        elsif(notification.device_type.downcase == 'visiom')
               #Send a post request to the VisioM server. Url is of the format 'http://thewebsite.net'
               #device_id should be the URL of the car
          puts("In VisioM => " + notification.notification_id.to_s)
          #Only send notifications to VisioM if the message type is either Driver pick up alert or User join request
          notifObj = Notification.find(notification.notification_id)
          if(notifObj.message_type == '1' || notifObj.message_type == '7')
            puts("IN FOR LOOP")
            MessageSender.send_visiom_notification(notification.device_id, notification.message, notification.notification_id, notifObj)
            puts("BEFORE UPDATE")
            Notification.update_status(notification.notification_id, notification.message)
          else
            puts("UPDATE: VisoM => Ignoring message type -->" + notifObj.message_type.to_s)
          end
        end
      rescue Exception => e
        puts("ERROR: While sending push notification: "+ notification.notification_id.to_s + " == Exception => " + e.inspect)
      end
    end
  end

  #This function sends push notificaiton to android devices. It takes the token of android device and notification message as output.
  def self.send_android_notification(token, message)
    gcm = GCM.new('AIzaSyDEH4T5dB9zA9bMbMyErENwb_CAf5tARYE') #TODO Initialize it only one time at app start
    #AIzaSyDNjxSCSc_zRBlC8jHpqxWgP1crx41B0IA
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

	puts("Response of android sender")
    #puts(response[:body])
	puts(response)
	
	
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
    pusher = Grocer.pusher(certificate: Rails.root.to_s + "/config/certificate/cert_apple_development.pem", passphrase: "simina", gateway: "feedback.sandbox.push.apple.com", port: 2196, retries: 3)
    puts(Rails.root.to_s + "/config/certificate/cert_apple_development.pem")
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
  def self.send_visiom_notification(url,message, notification_id, notifObj)

    #{
     #   "type": "Driver Pickup Alert",
      #  "id": 6,
       # "name": "TUMitfahrer",
        #"address": "address",
        #"image": "image"

    #Extra:
    # destination longtitude
    # destination lattitude
    # call back URL
    #
    #}

    #TODO: Find image URL, type of notification
    #TODO: The function should work only for 2 types of notification ... driver pickup and accept/decline

    message_type = notifObj.message_type

    callbackURL = ''
    latitude = 0
    longitude = 0

    puts("1")

    if(message_type == '1')
      message_type_string = 'Driver Pickup Alert'

      ride = Ride.find(notifObj.ride_id)
      latitude = ride.destination_latitude
      longitude = ride.destination_longitude
    else if (message_type == '7')
        message_type_string = 'User Join Request'

        #Create call back url for accept/decline user join request
        request_id = notifObj.extra
        request = Request.find(request_id)
        #http://localhost:3000/api/v2/rides/8/requests/5?passenger_id=2
        callbackURL = '/api/v2/rides_visiom/' + request.ride_id.to_s + '/requests/' + request_id.to_s + '?passenger_id=' + request.passenger_id.to_s
       end
    end

    puts("2")
    user_image_url = ''

    #json_string ='{
     #               \"type\":    ' + message_type_string +  ',
      #              \"id\":      ' + notification_id.to_s + ',
       #             \"name\":        "TUMitfahrer",
        #            \"address\": ' + message +              ',
         #           \"image\":   ' +  user_image_url +      ',
          #          \"url\":     ' + callbackURL +          ',
           #         \"latt\":    ' + latitude.to_s +        ',
            #        \"long\":    ' + longitude.to_s +       '
             #    }'


    params = {'type' => message_type_string , 'id' => notification_id , 'name' => message, 'address'=>  '','image'=> user_image_url,
              'url'=> callbackURL, 'latt' =>latitude.to_s , 'long' => longitude.to_s}
    json_headers = {"Content-Type" => "application/json",
                    "Accept" => "application/json"}

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)

    puts("PARAM JSON =>" + params.to_json.to_s)

    response = http.put(uri.path, params.to_json, json_headers)
    puts(response.body)


    #response = Net::HTTP.post_form(URI.parse(url), {'notification'=>json_string}
    #response = Net::HTTP.post_form(URI.parse(url), json_string, headers)
    #response = Net::HTTP.post_form(URI.parse(url), {'notification'=>message})
    #response.code #TODO: Add check if required based on the code
    #puts response.body
  end
end
