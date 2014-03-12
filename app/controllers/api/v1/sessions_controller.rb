class Api::V1::SessionsController < ApiController
  respond_to :json, :xml

  def create
    email, password = ActionController::HttpAuthentication::Basic::user_name_and_password(request)

    @user = User.find_by(email: email.downcase)
    if @user && @user.authenticate(password)
      if @user.api_key.nil?
        User.generate_api_key(@user)
      end
      render json: @user
    else
      render json: {:message => "User couldn't be added to the database"}
    end
  end
end