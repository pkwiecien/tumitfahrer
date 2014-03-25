class Api::V1::PassengersController < ApiController
  respond_to :xml, :json

  # GET /api/v1/rides/:ride_id/passengers
  def index
    if params.has_key?(:ride_id)
      ride = Ride.find_by(id: params[:ride_id])
      return respond_with passengers: [], status: 400 if ride.nil?

      passengers = ride.passengers
      result_passengers = []
      passengers.each do |p|
        exported_passenger = p.attributes
        exported_passenger[:contribution_mode] = ride[:contribution_mode]
        result_passengers.append(exported_passenger)
      end
      respond_with passengers: result_passengers, status: :ok
    else
      respond_with passengers: [], status: :bad_request
    end
  end

  # PUT /api/v1/rides/:ride_id/passengers/:id
  def update
    passenger = User.find_by(id: params[:id])
    ride = Ride.find_by(id: relationship.ride_id)

    if passenger.nil? || ride.nil?
      respond_to do |format|
        format.xml { render xml: {:status => :bad_request} }
        format.any { render json: {:status => :bad_request} }
      end
    end

    relationship = Relationship.find_by(user_id: passenger.id, is_driving: false, driver_ride_id: params[:ride_id])
    ride.update_attributes(user_params)
    respond_to do |format|
      format.xml { render xml: {:status => :ok} }
      format.any { render json: {:status => :ok} }
    end
  end

  private

  def user_params
    params.require(:passenger).permit(:contribution_mode, :realtime_km)
  end


end