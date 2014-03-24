class Api::V1::FriendsController < ApiController
  respond_to :xml, :json

  def index
    @user = User.find_by(id: params[:user_id])
    return respond_with :status => 400 if @user.nil?

    @friends = @user.friends
    respond_with @friends, :each_serializer => LegacyUserSerializer
  end

  def show

  end

  def create
  end


end