class Api::V2::RatingsController < ApiController
  respond_to :xml, :json

  # GET /api/v2/users/:user_id/ratings?given=true
  def index
    user_from_api_key = User.find_by(api_key: request.headers[:apiKey])
    return render json: {ratings: [], message: "Access denied"}, status: :unauthorized if user_from_api_key.nil?

    user = User.find_by(id: params[:user_id])
    return respond_with :ratings => [], :status => :not_found if user.nil?

    if params.has_key?(:given) && params[:given] == true
      respond_with user.ratings, status: :ok
    else
      respond_with user.ratings_received, status: :ok
    end

  end

  # POST /api/v2/users/:user_id/ratings?to_user_id=X&ride_id=Y&rating_type=Z
  def create
    user_from_api_key = User.find_by(api_key: request.headers[:apiKey])
    return render json: {rating: [], message: "Access denied"}, status: :unauthorized if user_from_api_key.nil?

    user = User.find_by(id: params[:user_id])
    return respond_with rating: [], :status => :not_found if user.nil?

    @rating = user.give_rating_to_user params[:to_user_id], params[:ride_id], params[:rating_type].to_i

    unless @rating.nil?
      render json: @rating, status: :ok
    else
      respond_with rating: [], status: :bad_request
    end

  end


end