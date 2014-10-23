class PasswordResetsController < ApplicationController
  def create
    user = User.find_by_email(params[:email])
    new_password = User.generate_new_password
    hashed_password = User.generate_hashed_password(new_password)
    user.update_attributes(password: hashed_password, password_confirmation: hashed_password)
    UserMailer.forgot_email(user,new_password).deliver
    flash[:success] = "Email sent with password reset instructions"
    redirect_to root_url

  end
end
