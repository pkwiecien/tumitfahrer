class Api::V1::PassengersController < ApiController
  respond_to :xml, :json

  def index
    if params.has_key?(:ride_id)
      ride = Ride.find_by(id: params[:ride_id])
      return respond_with :status => 400 if ride.nil?
      passengers = ride.passengers
      result_passengers = []
      passengers.each do |p|
        exported_passenger = p.attributes
        exported_passenger[:contribution_mode] = ride[:contribution_mode]
        result_passengers.append(exported_passenger)
      end
      respond_with :passengers => result_passengers
    else
      respond_with :status => 400
    end
  end

  def show

  end

  def create
    begin
      user = User.find_by(id: params[:user_id])
      from_user = User.find_by(id: params[:from_user_id])
      result = user.ratings.create!(from_user: from_user.id, ride_id: params[:ride_id], rating_type: params[:rating_type])
      respond_with :status => 200
    rescue
      respond_with :status => 400
    end
  end

  def update
    if params.has_key?(:ride_id)
      passenger = User.find_by(id: params[:id])
      return respond_with :status => 400 if passenger.nil?

      relationship = Relationship.find_by(user_id: passenger.id, is_driving: false, driver_ride_id: params[:ride_id])
      ride = Ride.find_by(id: relationship.ride_id)
      logger.debug "RIde: #{ride.to_s} and param: #{params} and last one #{params[:passenger][:realtime_km]}"
      ride.update_attributes(user_params)
      respond_with :status => 200
    else
      respond_with :status => 400
    end
  end

  private

  def user_params
    params.require(:passenger).permit(:contribution_mode, :realtime_km)
  end


end