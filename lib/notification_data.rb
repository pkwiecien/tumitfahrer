class NotificationData
    attr_accessor :notification_id
    attr_accessor :message
    attr_accessor :device_id
    attr_accessor :device_type

    def initialize(notification_id,message,device_id,device_type)
      @notification_id = notification_id
      @message = message
      @device_id = device_id
      @device_type = device_type
    end
end