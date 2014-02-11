class Api::V1::SessionsController < ApiController
  respond_to :json, :xml

  def create
    @user = User.find_by(email: request.headers['email'].downcase)
    logger.debug request.headers['email']
    logger.debug request.headers['password']
    if @user && @user.authenticate(request.headers['password'])
      if @user.api_key.nil?
        User.generate_api_key(@user)
      end
      render json: @user
    else
      render json: {:message => "User couldn't be added to the database"}
    end
  end
end