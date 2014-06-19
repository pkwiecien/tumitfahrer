require 'digest/sha2'
class SessionsController < ApplicationController

  def new

  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    hashed_password = Digest::SHA512.hexdigest(params[:session][:password]+'toj369sbz1f316sx')
    logger.debug "Hashed password: #{hashed_password}, authenticate user: #{user.authenticate(hashed_password)}"

    if user && user.authenticate(hashed_password)
      sign_in user
      #redirect_back_or user
      render :json => { :status => :ok, :message => "Success!" }
    else
      flash.now[:danger] = "Invalid user name or password!"
      render :json => { :status => :not_ok, :message => "Invalid email or password!" }
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
