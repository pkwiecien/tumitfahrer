class UserObserver < ActiveRecord::Observer

  def create(user)
    UserMailer.deliver_welcome_email(user,new_password)
  end

  def reset_passwd(user)
    UserMailer.deliver_recovery_mail(mail)
  end
end