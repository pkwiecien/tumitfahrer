module GcmUtils

  def self.send_android_push_notifications(registration_ids, options)

    gcm = GCM.new("AIzaSyAOIFGwYitZ12XJu1-DOXuZAa2UaJk97F8")

    options = {data: options}
    response = gcm.send_notification(registration_ids, options)

  end
end
