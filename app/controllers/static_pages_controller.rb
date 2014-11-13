class StaticPagesController < ApplicationController
  def home
  end

  def help
  end

  def about

  end

  def contact

  end

  def contact_us
    UserMailer.contact_email(params[:Email], params[:Name], params[:Title], params[:Message]).deliver
    flash[:success] = "Your message has been sent successfully"
    redirect_to root_path
  end

  def team

  end
  def privacy

  end

  def terms

  end
end
