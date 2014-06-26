class UserMailer < ActionMailer::Base
  default from: "tumitfahrer@gmail.com"

  def welcome_email(user, new_password)
    @user = user
    @new_password = new_password
    mail(to: @user.email, subject: 'Welcome to TUMitfahrer')
  end


end
