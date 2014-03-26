class UserMailer < ActionMailer::Base
  default from: "noremy@gmail.com"

  def welcome_email(user, new_password)
    @user = user
    @new_password = new_password
    mail(to: 'noremy@gmail.com', subject: 'Welcome to TUMitfahrer')
  end


end
