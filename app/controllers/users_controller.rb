class UsersController < ApplicationController
  before_action :signed_in_user, only: [:edit, :update, :show]
  before_action :right_user, only: [:edit, :update]

  def new
    if signed_in?
      redirect_to current_user
    else
      @user = User.new
    end
  end

  def create
    @user = User.new(user_params)
    if @user.save
      respond_to do |format|
        format.html sign_in @user
        flash[:success] = "Welcome to TUMitfahrer!"
        redirect_to @user
      end

    else
      render 'new'
    end
  end

  def show
    @user = User.find(params[:id])
    @rides = @user.rides.paginate(page: params[:page])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :department, :password, :password_confirmation)
  end

  def right_user
    @user = User.find(params[:id])
    redirect_to root_url unless current_user?(@user)
  end
end

