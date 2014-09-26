class Api::V2::ForgotsController < ApiController
  respond_to :json, :xml

  # POST /api/v2/forgot?email=abc
  def create
    @user = User.find_by(email: params[:email])

    if @user != nil
      # if user was created successfully then send a welcome email
      new_password = User.generate_new_password
      hashed_password = User.generate_hashed_password(new_password)
      @user.update_attributes!(password: hashed_password, password_confirmation: hashed_password)
      UserMailer.forgot_email(@user, new_password).deliver

      respond_to do |format|
        format.json { render json: {:message => "Reminder sent"}, status: :created }
        format.xml { render xml: {:status => :created, :message => "Reminder sent" } }
      end
    else
      respond_to do |format|
        format.json { render json: {:status => :bad_request, :message => "Could not send password reminder"} }
        format.xml { render xml: {:status => :bad_request, :message => "Could not send password reminder"} }
      end
    end
  end


end
