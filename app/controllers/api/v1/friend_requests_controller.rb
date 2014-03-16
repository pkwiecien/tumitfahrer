class Api::V1::FriendRequestsController < ApiController
  respond_to :xml, :json

  def index
    @user = User.find_by(id: params[:user_id])
    @friends_requests = @user.requesting_friends

    respond_to do |format|
      format.json { render json: @friends_requests, :each_serializer => LegacyUserSerializer }
      format.xml { render xml: @friends_requests }
    end

  end

  def show

  end

  def create
  end


end