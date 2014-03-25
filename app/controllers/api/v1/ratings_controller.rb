class Api::V1::RatingsController < ApiController
  respond_to :xml, :json

  # GET /api/v1/users/:user_id/ratings
  # optionally GET /api/v1/users/:user_id/ratings?pending
  def index
    user = User.find_by(id: params[:user_id])
    return :ratings => [], :status => :bad_request if user.nil?

    result = []
    # generate pending ratings
    if params.has_key?(:pending)
      user.rides_as_passenger.each do |ride|
        if Rating.find_by(from_user_id: user.id, to_user_id: ride.driver.id, ride_id: ride.id).nil?
          pending_rating = {}
          pending_rating[:from_user_id] = user.id
          pending_rating[:to_user_id] = ride.driver.id
          pending_rating[:ride_id] = ride.id
          result.append(pending_rating)
        end
      end
      respond_with ratings: result, status: :ok
    else
      #generate ratings given
      ratings = user.ratings_given + user.ratings_received
      result = []
      ratings.each do |r|
        rating = {}
        rating[:from_user_id] = r[:from_user_id]
        rating[:to_user_id] = r[:to_user_id]
        rating[:ride_id] = r[:ride_id]
        result.append(rating)
      end
      respond_with ratings: result, status: :ok
    end
  end

  # POST /api/v1/users/:user_id/ratings?to_user_id=X&ride_id=Y&rating_type=Z
  def create
    user = User.find_by(id: params[:user_id])
    rating = user.ratings_given.create!(to_user_id: params[:to_user_id], ride_id: params[:ride_id],
                                        rating_type: params[:rating_type])

    unless rating.nil?
      respond_with rating: rating, status: :ok
    else
      respond_with rating: rating, status: :bad_request
    end
  end


end