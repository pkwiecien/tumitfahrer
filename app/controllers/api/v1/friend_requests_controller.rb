class Api::V1::FriendRequestsController < ApiController
  respond_to :xml, :json

  def index
    @user = User.find_by(id: params[:user_id])
    return respond_with :status => 400 if @user.nil?

    @friends_requests = @user.requesting_friends
    respond_with @friends_requests, :each_serializer => LegacyUserSerializer
  end

  def show

  end

  def create
    begin
      user = User.find_by(id: params[:user_id])
      other_user = User.find_by(id: params[:to_user_id])
      result = user.send_friend_request!(other_user)

      respond_with result
    rescue
      respond_with :status => 400
    end
  end

  def update
    begin
      user = User.find_by(id: params[:user_id])
      other_user = User.find_by(id: params[:id])

      user.handle_friend_request(other_user, params[:accept])
      respond_with :status => 200
    rescue
      respond_with :status => 400
    end
  end


end