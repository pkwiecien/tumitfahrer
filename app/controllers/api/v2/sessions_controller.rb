class Api::V2::SessionsController < ApiController
  respond_to :json, :xml

  def create
    email, hashed_password = ActionController::HttpAuthentication::Basic::user_name_and_password(request)

    @user = User.find_by(email: email.downcase)

    logger.debug "authenticating user for #{email} and #{hashed_password}"

    if @user && @user.authenticate(hashed_password)
      if @user.api_key.nil?
        User.generate_api_key(@user)
      end

      logger.debug "logging in user #{@user.to_s}"
      respond_to do |format|
        format.json { render json: @user }
        format.xml { render xml: {:attempt => "true", "user_id" => "31"} }
      end
    else
      logger.debug "could not log in user #{@user.to_s}"

      respond_to do |format|
        format.json { render json: {:message => "User couldn't be added to the database"} }
        format.xml { render xml: {:attempt => "dupa", :user_id => "0"} }
      end

    end
  end
end