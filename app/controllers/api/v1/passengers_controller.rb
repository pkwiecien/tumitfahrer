class Api::V1::PassengersController < ApiController
  respond_to :xml, :json

  def index
    if params.has_key?(:ride_id)
      ride = Ride.find_by(id: params[:ride_id])
      passengers = ride.passengers
      result_passengers = []
      passengers.each do |p|
        exported_passenger = p.attributes
        exported_passenger[:contribution_mode] = ride[:contribution_mode]
        result_passengers.append(exported_passenger)
      end
      respond_to do |format|
        format.json {render json: {:passengers => result_passengers}}
        format.xml {render xml: {:passengers => result_passengers}}
      end
    else
      render json: {:status => "400"}
    end
  end

  def show

  end

  def create
    user = User.find_by(id: params[:user_id])
    from_user = User.find_by(id: params[:from_user_id])
    result = user.ratings.create!(from_user: from_user.id, ride_id: params[:ride_id], rating_type: params[:rating_type])

    unless result.nil?
      render json: {:result => "1"}
    else
      render json: {:result => "0"}
    end
  end


end