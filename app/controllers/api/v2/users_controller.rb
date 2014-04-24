class Api::V2::UsersController < ApiController
  respond_to :xml, :json

  # GET /api/v1/users/
  def index
    @users = User.all
    respond_with @users, status: :ok
  end

  # GET /api/v1/users/:id
  def show
    # check if there an authentication header, if so consume it and return more
    if !request.headers[:Authorization].nil?
      email, hashed_password = ActionController::HttpAuthentication::Basic::user_name_and_password(request)
    end

    # if user could not be found by id then find him by email
    @user = User.find_by(id: params[:id])
    if !@user
      @user = User.find_by(email: email)
    end

    if @user && !email.nil? && !hashed_password.nil? && @user.authenticate(hashed_password)

      respond_with @user, status: :ok
    else
      respond_with status: :bad_request, message: "Could not retrieve the user"
    end
  end

  # POST /api/v2/users
  def create
    # generate new password for a new user
    new_password = User.generate_new_password
    hashed_password = User.generate_hashed_password(new_password)
    @user = User.new(user_params.merge(password: hashed_password, password_confirmation: hashed_password))

    if @user.save
      # if user was created successfully then send a welcome email
      UserMailer.welcome_email(@user, new_password).deliver

      respond_to do |format|
        format.json { render json: {:message => "User created"}, status: :created }
        format.xml { render xml: {:status => :created, :message => "User created" } }
      end
    else
      respond_to do |format|
        format.json { render json: {:status => :bad_request, :message => "Could not create the user"} }
        format.xml { render xml: {:status => :bad_request, :message => "Could not create the user"} }
      end
    end
  end

  private

  # TODO: introduce authentication by api key
  def authenticate_user
    @current_user = User.find_by_api_key(params[:api_key])
  end

  def current_user
    @current_user
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :department, :is_student)
  end

end