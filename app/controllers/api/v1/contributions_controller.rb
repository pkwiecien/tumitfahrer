class Api::V1::ContributionsController < ApiController
  respond_to :xml, :json

  def index
    @user = User.find_by(id: params[:user_id])
    @contributions = @user.contributions

    respond_to do |format|
      format.json { render json: {:contributions => @contributions} }
      format.xml { render xml: @contributions }
    end

  end

  def show

  end

  def create
  end


end
