class Api::V1::SessionsController < ApiController
  respond_to :json, :xml

  def create
    email, password = ActionController::HttpAuthentication::Basic::user_name_and_password(request)

    @user = User.find_by(email: email.downcase)
    if @user && @user.authenticate(password)
      if @user.api_key.nil?
        User.generate_api_key(@user)
      end
      respond_to do |format|
        format.json { render json: @user }
        format.xml { render xml: {:attempt => "true", "user_id" => "31"} }
      end
    else
      respond_to do |format|
        format.json { render json: {:message => "User couldn't be added to the database"} }
        format.xml { render xml: {:attempt => "false", :user_id => "0"} }
      end

    end
  end
end