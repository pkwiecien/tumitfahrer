class NotificationData
    attr_accessor :message
    attr_accessor :device_id
    attr_accessor :device_type

    def initialize(message,device_id,device_type)
      @message = message
      @device_id = device_id
      @device_type = device_type
    end
end