class Api::V1::FriendsController < ApiController
  respond_to :xml, :json

  def index
    @user = User.find_by(id: params[:user_id])
    @friends = @user.friends
    respond_to do |format|
      format.json { render json: @friends, :each_serializer => LegacyUserSerializer }
      format.xml { render xml: @friends }
    end

  end

  def show

  end

  def create
  end


end