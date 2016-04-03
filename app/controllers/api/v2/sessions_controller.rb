class Api::V2::SessionsController < ApiController
  respond_to :json, :xml

  # POST /api/v2/sessions
  # create new session for the user
  def create
    # retrieve encrypted credentials
    email, hashed_password = ActionController::HttpAuthentication::Basic::user_name_and_password(request)

    @user = User.find_by(email: email.downcase)

    if @user && @user.authenticate(hashed_password)
      if @user.api_key.nil?
        User.generate_api_key(@user)
      end
      respond_with @user, status: :ok
    else
      respond_to do |format|
        message = "Can't create session for requested user. Check credentials."
        format.json { render json: {message: message}, status: :bad_request }
        format.xml { render xml: {message: message}, status: :bad_request }
      end

    end
  end
end