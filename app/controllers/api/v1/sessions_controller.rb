class Api::V1::SessionsController < ApiController

  # POST /api/v1/sessions/
  # authenticate user
  def create
    email, hashed_password = ActionController::HttpAuthentication::Basic::user_name_and_password(request)

    @user = User.find_by(email: email.downcase)

    logger.debug "authenticating user for #{email} and #{hashed_password}"

    if @user && @user.authenticate(hashed_password)
      if @user.api_key.nil?
        User.generate_api_key(@user)
      end

      send_android_push(@user)

      respond_to do |format|
        format.json { render json: @user }
        format.xml { render xml: {:attempt => "true", "user_id" => @user.id} }
      end
    else
      logger.debug "could not log in user #{@user.to_s}"
      respond_to do |format|
        format.json { render json: {:status => 400, :message => "User couldn't be added to the database"} }
        format.xml { render xml: {:attempt => "false", :user_id => "-1"} }
      end
    end

  end

  private

  def send_android_push(user)
    begin
      devices = user.devices.where(platform: "android")
      registration_ids = []
      devices.each do |d|
        registration_ids.append(d[:token])
      end

      options = {}
      options[:type] = :nachricht
      options[:message] = "Push notifications work!"
      options[:time] = Time.now
      options[:absender] = user.id

      logger.debug "Sending push notification with reg_ids : #{registration_ids} and options: #{options}"
      response = GcmUtils.send_android_push_notifications(registration_ids, options)
      logger.debug "Response: #{response}"
    rescue
      logger.debug "Could not send push notification"
    end
  end
end