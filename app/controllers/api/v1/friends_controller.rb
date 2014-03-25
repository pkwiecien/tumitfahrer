class Api::V1::FriendsController < ApiController
  respond_to :xml, :json

  # GET /api/v1/users/:user_id/friends
  def index
    @user = User.find_by(id: params[:user_id])
    return respond_with friends: [], status: :bad_request if @user.nil?

    @friends = @user.friends
    respond_with @friends, :each_serializer => LegacyUserSerializer, status: :ok
  end

end