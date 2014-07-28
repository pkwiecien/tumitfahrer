require 'digest/sha2'
require 'message_sender'

class UsersController < ApplicationController
  before_action :signed_in_user, only: [:edit, :update, :show]
  before_action :right_user, only: [:edit, :update]

  def check_email
    @user = User.find_by_email(params[:user][:email])

    respond_to do |format|
      format.json { render :json => !@user }
    end
  end




  def new
    if signed_in?
      redirect_to current_user
    else
      @user = User.new
    end
  end

  def create

    params[:user][:password] = Digest::SHA512.hexdigest(params[:user][:password]+Tumitfahrer::Application::SALT)
    params[:user][:password_confirmation] = params[:user][:password]

    logger.debug "Env variable is: "
    logger.debug "here: #{ENV['S3_BUCKET_NAME']}"

    @user = User.new(user_params)
    if @user.save
        sign_in @user
        flash[:success] = "Welcome to TUMitfahrer!"
        redirect_to @user
    else
      render 'new'
    end

  end

  def show
    #TODO: REMOVE THE FOLLOWING CODE JUST FOR TESTING BY BEHROZ
    #@result = Notification.get_notification_list
    #MessageSender.send_next_batch()

    #TODO: END
    @user = User.find_by(id: params[:id])
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
    params.require(:user).permit(:first_name, :last_name, :email, :department,
                                 :password, :password_confirmation, :avatar)
  end

  def right_user
    @user = User.find(params[:id])
    redirect_to root_url unless current_user?(@user)
  end
end

