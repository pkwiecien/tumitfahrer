class Api::V1::UsersController < ApiController
  respond_to :xml, :json

  def index
    unless params[:email].nil?
      # todo: check if it should be here. URL is users?username=abc
      @user = User.find_by(email: params[:email])
      respond_with @user, serializer: LegacyUserSerializer
    else
      @users = User.all
      respond_with @users, each_serializer: LegacyUserSerializer
    end
  end

  def show_user_for_email
    respond_with :status => "working"
  end

  def show
    # check if there an authentication header, if so consume it and return more
    if !request.headers[:Authorization].nil?
      email, hashed_password = ActionController::HttpAuthentication::Basic::user_name_and_password(request)
    end
    @user = User.find_by(id: params[:id])
    if !@user
      @user = User.find_by(email: email)
    end

    if @user && !email.nil? && !hashed_password.nil? && @user.authenticate(hashed_password)
      respond_with @user, serializer: LegacyUserSerializer
    else
      respond_to do |format|
        format.json { render json: @user, serializer: LegacyUserSerializer }
        format.xml { render xml: {:email => @user[:email]} }
      end
    end
  end

  def create
    logger.debug "Creating user for params: #{user_params}"
    @user = User.new(user_params)
    if @user.save
      respond_to do |format|
        format.json { render json: {:message => "User added to the database", :api_key => @user.api_key, :id => @user.id} }
        format.xml { render xml: {:username => "true", :mail => "true", :id => @user.id} }
      end
    else
      respond_to do |format|
        format.json { render json: {:message => "User couldn't be added to the database"} }
        format.xml { render xml: {:username => "false", :mail => "false"} }
      end
    end
  end

  def update
    user = User.find_by(id: params[:id])

    respond_with :status => 400 if user.nil?

    user.update_attributes(update_params)
    if user.save
      respond_with :aenderung => true
    else
      respond_with :aenderung => false
    end
  end

  private

  def authenticate_user
    @current_user = User.find_by_api_key(params[:api_key])
  end

  def current_user
    @current_user
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :department, :password,
                                 :password_confirmation, :is_student)
  end

  def update_params
    params.require(:user).permit(:id, :phone_number, :rank, :exp, :car, :unbound_contributions, :department,
                                 :password, :password_confirmation, :gamification)
  end

end