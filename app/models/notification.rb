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

  def self.update_status(id,status)
    @notification = Notification.find(id)
    @notification.status = status
    @notification.save
  end

  def self.insert_notification(user_id,ride_id,message_type,datetime,status)
    @notification = Notification.new
    @notification.user_id = user_id
    @notification.ride_id = ride_id
    @notification.message_type = message_type
    @notification.date_time = datetime
    @notification.status = status

    @notification.save
  end

  def self.delete_notification(id)
    Notification.delete(id)
  end

  def self.get_notification_list
    startTime = Time.now
    endTime = Time.now + 5*60  #next 5 mins
    #@notifications = Notification.where(:status => false).where(:date_time => startTime...endTime)
    notifications = Notification.where(:status=>false)

    #Pass this notification object to another class. That can generate a string message
    # based on message type. This function will return a custom object List
    # Message, device type
    #TODO: Error handling

    result = Array.new
    notifications.each do |notification|  #loop through all the notifications
      message = Notification.get_message(notification)  #get the constructed message based on message type

      platform = notification.user.devices.platform  #get platform and device id
      device_id = notification.user.devices.token  #get platform and device id

      data = NotificationData.new(message,device_id,platform) #initialize a custom object

      result << data  #append the object in array and return the array
    end #Loop through notifications
  end

  def self.get_message(notification)
    case notification.message_type
      when '1'
        Notification.construct_message_1(notification)
      when '2'
        Notification.construct_message_2(notification)
      else

    end
  end

  def self.construct_message_1(notification)
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

    ride = Ride.new
    ride.user_id = user_id
    ride.id = ride_id
    result = ride.passengers_of_ride    #call passsenger_of_ride function

    message = "TumMitFahrer: Alert (Reminder for Pickup) Time: #{time} Location: #{departure} Passenger: "

    #if result is empty

    result.each do |user|
      message += user.last_name
    end #return the final message generated

    message
  end

  def self.construct_message_2(notification)
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
    result = ride.driver    #get driver  -- Should only return 1 row

    message = "TumMitFahrer: Alert (Passenger Ride Alert) Time: #{time} Location: #{departure} Driver: #{result}"


  end
end
