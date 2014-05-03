class Api::V2::SessionsController < ApiController
  respond_to :json, :xml

  # POST /api/v2/sessions
  # create new session for the user
  def create
    # retrieve encrypted credentials
    email, hashed_password = ActionController::HttpAuthentication::Basic::user_name_and_password(request)
    logger.debug "authenticating user for #{email} and #{hashed_password}"

    @user = User.find_by(email: email.downcase)

    if @user && @user.authenticate(hashed_password)
      logger.debug "logging in user #{@user.to_s}"
      if @user.api_key.nil?
        User.generate_api_key(@user)
      end
      respond_with @user, status: :ok
    else
      logger.debug "could not log in user #{@user.to_s}"

      respond_to do |format|
        format.json { render json: {status: :bad_request, :message => "User couldn't be added to the database"} }
        format.xml { render xml: {status: :bad_request, :message => "User couldn't be added to the database"} }
      end

    end
  end
end