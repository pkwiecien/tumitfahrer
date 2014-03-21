class Api::V1::RatingsController < ApiController
  respond_to :xml, :json

  def index
    user = User.find_by(id: params[:user_id])
    result = []

    # generate pending ratings
    if params.has_key?(:pending)
      user.rides_as_passenger.each do |ride|
        if Rating.find_by(from_user_id: user.id, to_user_id: ride[:driver_id], ride_id: ride.id).nil?
          pending_rating = {}
          pending_rating[:from_user_id] = user.id
          pending_rating[:to_user_id] = ride[:driver_id]
          pending_rating[:ride_id] = ride.id
          result.append(pending_rating)
        end
      end
      render json: {:ratings => result}
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
      render json: {:ratings => result}
    end
  end

  def show

  end

  def create
    rating = Rating.create(from_user_id: params[:user_id], to_user_id: params[:to_user_id],
                                        ride_id: params[:ride_id], rating_type: params[:rating_type])

    if rating.save
      render json: {:status => 200}
    else
      render json: {:status => 400}
    end
  end


end