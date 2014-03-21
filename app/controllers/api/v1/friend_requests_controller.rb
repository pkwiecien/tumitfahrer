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
    user = User.find_by(id: params[:user_id])
    other_user = User.find_by(id: params[:to_user_id])
    result = user.send_friend_request!(other_user)

    # todo: render OK
    respond_to do |format|
      format.json { render json: result }
      format.xml { render xml: result }
    end
  end

  def update
    user = User.find_by(id: params[:user_id])
    other_user = User.find_by(id: params[:id])

    user.handle_friend_request(other_user, params[:accept])
    render json: {:status => 200}

  end


end