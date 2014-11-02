class UserMailer < ActionMailer::Base
  default from: "tumitfahrer@gmail.com"

  def welcome_email(user, new_password)
    @user = user
    @new_password = new_password
    mail(to: @user.email, subject: 'Welcome to TUMitfahrer')
  end

  def forgot_email(user, new_password)
    @user = user
    @new_password = new_password
    mail(to: @user.email, subject: 'TUMitfahrer: Password reminder')
  end

  def contact_email(email_id, name, title, message)
    @email = email_id
    @name = name
    @title = title
    @message = message
    mail(from: @email, to: ENV["EMAIL"], subject: 'TUMitfahrer: Feedback')
  end
end
