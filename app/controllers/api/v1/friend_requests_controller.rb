class Api::V1::FriendRequestsController < ApiController
  respond_to :xml, :json

  # GET /api/v1/users/:user_id/friend_requests
  def index
    @user = User.find_by(id: params[:user_id])
    return respond_with friends_requests: [], status: :not_found if @user.nil?

    @friends_requests = @user.requesting_friends
    respond_with @friends_requests, :each_serializer => LegacyUserSerializer
  end

  # POST /api/v1/users/:user_id/friend_requests
  def create
    begin
      user = User.find_by(id: params[:user_id])
      other_user = User.find_by(id: params[:to_user_id])
      result = user.send_friend_request!(other_user)

      respond_with result, status: :created
    rescue
      respond_with :result => [], status: :bad_request
    end
  end

  # PUT /api/v1/users/:user_id/friend_requests/2
  def update
    begin
      user = User.find_by(id: params[:user_id])
      other_user = User.find_by(id: params[:id])

      user.handle_friend_request(other_user, params[:accept])

      respond_to do |format|
        format.xml { render xml: {:status => :ok} }
        format.any { render json: {:status => :ok} }
      end
    rescue
      respond_to do |format|
        format.xml { render xml: {:status => :bad_request} }
        format.any { render json: {:status => :bad_request} }
      end
    end
  end

end