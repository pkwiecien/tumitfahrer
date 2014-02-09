class Api::V1::UsersController < ApiController
  respond_to :json, :xml

  def index
    @users = User.all
    respond_to do |format|
      format.json { render json: @users }
      format.xml { render xml: @users }
    end
  end

  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.json { render json: @user }
      format.xml { render xml: @user }
    end
  end

  def create
    @user = User.new(user_params)
    if @user.save
      render json: {:success => "User added to the database", :api_key => @user.api_key}
    else
      render json: {:error => "User couldn't be added to the database"}
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
    params.require(:user).permit(:first_name, :last_name, :email, :department, :password, :password_confirmation)
  end
end
