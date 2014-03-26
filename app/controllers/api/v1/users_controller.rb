class Api::V1::UsersController < ApiController
  respond_to :xml, :json

  # GET /api/v1/users/
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

  # GET /api/v1/users/:id
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

  # POST /api/v1/users
  def create
    new_password = User.generate_new_password
    hashed_password = User.generate_hashed_password(new_password)
    @user = User.new(user_params.merge(password: hashed_password, password_confirmation: hashed_password))

    if @user.save
      UserMailer.welcome_email(@user, new_password).deliver

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

  # PUT /api/v1/users/:id
  def update
    user = User.find_by(id: params[:id])
    return respond_with :aenderung => false, :status => :not_found if user.nil?

    user.update_attributes(update_params)
    if user.save
      respond_with :aenderung => true, status: :ok
    else
      respond_with :aenderung => false, status: :ok
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
    params.require(:user).permit(:first_name, :last_name, :email, :department, :is_student)
  end

  def update_params
    params.require(:user).permit(:id, :phone_number, :rank, :exp, :car, :unbound_contributions, :department,
                                 :password, :password_confirmation, :gamification)
  end

end