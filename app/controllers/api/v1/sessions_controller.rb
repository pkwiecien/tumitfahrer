class Api::V1::SessionsController < ApiController

  def create

    email, hashed_password = ActionController::HttpAuthentication::Basic::user_name_and_password(request)

    @user = User.find_by(email: email.downcase)

    logger.debug "authenticating user for #{email} and #{hashed_password}"

    if @user && @user.authenticate(hashed_password)
      if @user.api_key.nil?
        User.generate_api_key(@user)
      end

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
end