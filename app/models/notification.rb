require 'ride'
require 'notification_data'

# Schema Information
# Table name: notifications
#  id                      :integer          not null, primary key
#  user_id                 :integer
#  ride_id                 :integer
#  message_type            :integer          #The type of message we have to send.
#  date_time               :datetime         #datetime at which we have to send the message
#  status                  :boolean          #current status of notificatino. false means that message not sent. true means message sent.
#  created_at              :datetime         not null
#  updated_at              :datetime         not null

class Notification < ActiveRecord::Base
  validates :user_id, presence: true
  validates :ride_id, presence: true
  validates :date_time, presence: true
  validates :message_type, presence: true
  #validates :status, presence: true  # TODO: status should also be mandatory
  belongs_to :user
  belongs_to :ride

  def self.get_all_notifications
    Notification.all
  end

  def self.get_notification(id)
    Notification.find(id)
  end

  #This function updates the status to 'sent' and save it in database
  def self.update_status(id,message)
    notification = Notification.find(id)
    notification.status = "sent"
    notification.message = message
    notification.save
  end

  #This function inserts the notification and sets the status to "not sent"
  def self.insert_notification(user_id,ride_id,message_type,datetime)
    notification = Notification.new
    notification.user_id = user_id
    notification.ride_id = ride_id
    notification.message_type = message_type
    notification.date_time = datetime
    notification.status = "not sent"

    if notification.save
      return notification
    end
  end

  def self.delete_notification(id)
    Notification.delete(id)
  end




  #This functions inserts the notification for driver_pickup_alert message.
  def self.driver_pickup(current_user_id, ride_id, departure_time)
    insert_notification(current_user_id , ride_id, 1, departure_time - 15*60) #Send notification to user 15 minutes before the pickup
  end

  #This function inserts the notification in the database table if the driver has accepted the request of a user. This notification will
  #be handled by accept_request_alert
  def self.accept_request(passenger_id, ride_id, ride_departure_time)
    notification = insert_notification(passenger_id,ride_id,5, Time.zone.now + 5*60) #Send notification to user within 5 minutes of acceptance of request
    insert_notification(passenger_id,ride_id,2, ride_departure_time - 15*60) #Send user reminder 15 min before the ride
  end

  #Controller method to insert decline_request_alert notification
  def self.decline_request(ride_id, passenger_id)
    insert_notification(passenger_id,ride_id,6, Time.zone.now + 5*60) #Send the notification to user within 5 minute of rejection of request
  end

  #This function inserts the notification in the database table for cancel_ride_alert notification message.
  def self.cancel_ride(ride_id,user_id)
    # 1- We need to destroy the notification that was created to remind the driver about the upcoming ride
    Notification.where(:ride_id => ride_id, :message_type => 1).destroy_all #TODO: check the notification exist or not

    # 2- We need to add notifications for passengers that user has canceled the ride
    ride = Ride.new
    ride.user_id = user_id
    ride.id = ride_id
    passenger_list = ride.passengers

    #loop through all the passengers and insert notification for each passenger in notification table
    passenger_list.each do |passenger|
      insert_notification(passenger.id, ride_id, 3, Time.zone.now + 5*60) #Send users notification within 5 minutes of cancellation of ride
    end
  end

  def self.user_join(ride_id)
    #Since the message should be sent to the driver. Get his user id and insert in the notification table
    ride = Ride.find(ride_id)
    user = ride.driver
    insert_notification(user.id , ride_id, 1, Time.zone.now + 5*60) #Send notification to user 5 minutes
  end

  #def self.reservation_cancelled() #Update method in rides_controller.... update the code and put the function over there
  #end





  def self.get_single_notification_data(notification)
    # 1- Find the user and its related devices
    # 2- Create a notification object and put it in the object
    # 3- Since there can be multiple devices so we have an array of NotificationData

    result = Array.new
    devices_list = notification.user.devices

    devices_list.each do |device|
      platform = device.platform  #get platform and device id
      device_id = device.token
      language = device.language

      message = Notification.get_message(notification, language)  #get the constructed message based on message type

      result << NotificationData.new(1,message,device_id,platform) #initialize a custom object
    end

    result
  end



  #This function gets the list of notifications that the cron job has to send in next 5 mins.
  def self.get_notification_list
    startTime = Time.zone.now
    endTime = Time.zone.now + 5*60  #next 5 mins
    #@notifications = Notification.where(:status => false).where(:date_time => startTime...endTime)
    notifications = Notification.where(:status=>'not sent') #TODO: revert it back to 5 min thing

    #TODO: Error handling

    result = Array.new
    notifications.each do |notification|  #loop through all the notifications
      devices_list = notification.user.devices

      devices_list.each do |device|
        platform = device.platform  #get platform and device id
        device_id = device.token
        language = device.language

        #Each device can have different language. So, we have to construct the message again in the loop
        message = Notification.get_message(notification, language)  #get the constructed message based on message type

        data = NotificationData.new(notification.id,message,device_id,platform) #initialize a custom object

        result << data  #append the object in array and return the array
      end
    end #Loop through notifications

    result  #return the result
  end

  #This function lists all the possible message types and there corresponding functions. Each function generates a string message that
  #needs to be sent as a notification
  def self.get_message(notification, language)
    case notification.message_type
      when '1'
        Notification.driver_pickup_alert(notification, language)
      when '2'
        Notification.passenger_ride_alert(notification, language)
      when '3'
        Notification.cancel_ride_alert(notification , language)
      when '4'
        Notification.reservation_cancelled_passenger_alert(notification, language)
      when '5'
        Notification.accept_request_alert(notification, language)
      when '6'
        Notification.decline_request_alert(notification, language)
      when '7'
        Notification.user_join_alert(notification, language)
      else
        #TODO: Handling this case
    end
  end

  #This functions generates a string notification for drivers that they have to pick up the passengers
  def self.driver_pickup_alert(notification, language)
    #2 - Driver Pick-up Alert
    #H=> TuMitfahrer: Alert
    #M=> Reminder for Pickup:
    #Time: 12:12:00
    #Location:
    #Passenger: , , ...
    departure = notification.ride.departure_place
    time = notification.ride.departure_time
    user_id = notification.user_id
    ride_id = notification.ride_id

    default_language = I18n.locale

    I18n.locale = language
    message = I18n.t(:driver_pickup_alert, time: time, departure: departure)
    #message = "TUMitFahrer: Alert (Reminder for Pickup) Time: #{time} Location: #{departure}"

    I18n.locale = default_language
    message
  end

  #This function generates a string notification for passengers that they have an upcoming ride
  def self.passenger_ride_alert(notification, language)
    #Passenger Ride Alert
    #H=> TuMitfahrer: Alert
    #M=> Reminder for Ride:
    #Time: 12:12:00
    #Location:
    #Driver:

    departure = notification.ride.departure_place
    time = notification.ride.departure_time
    user_id = notification.user_id
    ride_id = notification.ride_id

    ride = Ride.new
    ride.user_id = user_id
    ride.id = ride_id
    driver = get_driver_name(ride)    #get driver  -- Should only return 1 row

    default_language = I18n.locale
    I18n.locale = language
    message = I18n.t(:passenger_ride_alert, time: time, departure: departure, result: driver)
    I18n.locale = default_language
    #message = "TUMitFahrer: Alert (Passenger Ride Alert) Time: #{time} Location: #{departure} Driver: #{driver}"

    message
  end

  #This function generates a string notification for cancellation of ride. The notification is sent to all the passengers.
  def self.cancel_ride_alert(notification, language)
    #Cancel ride alert to passengers
    #H=> TuMitfahrer: Alert
    #M=> Ride Cancelled:
    #Driver , has cancelled the ride.
    #Time: ride
    #Location:
    #Reason: due to an unexpected event.

    departure = notification.ride.departure_place
    time = notification.ride.departure_time
    user_id = notification.user_id
    ride_id = notification.ride_id

    ride = Ride.new
    ride.user_id = user_id
    ride.id = ride_id
    driver = get_driver_name(ride)    #get driver  -- Should only return 1 row

    default_language = I18n.locale
    I18n.locale = language
    message = I18n.t(:cancel_ride_alert, driver: driver, time: time, departure: departure)
    I18n.locale = default_language

    #message = "TUMitFahrer: Alert (Ride Cancelled) Driver #{driver}, had cancelled the ride. Time: #{time} Location: #{departure} Reason: Due to an unexpected event."
    message
  end

  #This function generates a string notification for reservation cancellation. This notification is sent to the driver.
  def self.reservation_cancelled_passenger_alert(notification, language)
    #Reservation cancelled alert to driver
    #H=> TuMitfahrer: Alert
    #M=> Reservation Cancelled:
    #Passenger , is unable to join you.
    #Time: ride
    #Location:
    #Reason: due to an unexpected event.

    departure = notification.ride.departure_place
    time = notification.ride.departure_time
    user_id = notification.user_id
    ride_id = notification.ride_id
    passenger_name = notification.user.last_name + ", " + notification.user.first_name

    default_language = I18n.locale
    I18n.locale = language
    message = I18n.t(:reservation_cancelled_passenger_alert, passenger_name: passenger_name, time: time, departure: departure)
    I18n.locale = default_language

    #message = "TUMitFahrer: Alert (Reservation Cancelled) Passenger #{username}, had cancelled the ride. Time: #{time} Location: #{departure} Reason: Due to an unexpected event."
    message
  end

  #This function generates a string notification for acceptance of request by the driver. Message is sent to the passenger.
  def self.accept_request_alert(notification, language)
    #Accept request for ride from driver
    #H=> TUMitfahrer: Alert
    #M=> Request Accepted:
    #Driver , has accepted your request to join the ride.

    departure = notification.ride.departure_place
    time = notification.ride.departure_time
    user_id = notification.user_id
    ride_id = notification.ride_id

    ride = Ride.new
    ride.user_id = user_id
    ride.id = ride_id
    driver = get_driver_name(ride)

    #message = "TUMitFahrer: Alert (Request Accepted) Driver #{driver}, has accepted your request to join the ride."
    default_language = I18n.locale
    I18n.locale = language
    message = I18n.t(:accept_request_alert, driver: driver)
    I18n.locale = default_language

    message
  end

  #This function generates a string notification for declination of request by the driver. Message is sent to the passenger.
  def self.decline_request_alert(notification, language)
    #Accept request for ride from driver
    #H=> TUMitfahrer: Alert
    #M=> Request Declined:
    #Driver , has declined your request to join the ride.

    departure = notification.ride.departure_place
    time = notification.ride.departure_time
    user_id = notification.user_id
    ride_id = notification.ride_id
    username = notification.user.last_name + notification.user.first_name

    ride = Ride.new
    ride.user_id = user_id
    ride.id = ride_id
    driver = get_driver_name(ride)

    #message = "TUMitFahrer: Alert (Request Declined) Driver #{driver}, has declined your request to join the ride."

    default_language = I18n.locale
    I18n.locale = language
    message = I18n.t(:decline_request_alert, driver: driver)
    I18n.locale = default_language

    message
  end

  def self.user_join_alert(notification, language)
    #Accept request for ride from driver
    #H=> TUMitfahrer: Alert
    #M=> User Join:
    #A Passenger wants to join the ride..

    default_language = I18n.locale
    I18n.locale = language
    message = I18n.t(:user_join_alert)
    I18n.locale = default_language

    message
  end

  def get_driver_name(ride)
    user_driver = ride.driver
    user_driver.last_name + "," + user_driver.first_name
  end
end
