class Api::V1::RequestsController < ApiController
  respond_to :xml, :json

  def index
    user = User.find_by(id: params[:user_id])
    contributions = user.contributions

    respond_to do |format|
      format.json { render json: {:contributions => contributions} }
      format.xml { render xml: contributions }
    end
  end

  def show

  end

  def create
    user = User.find_by(id: params[:user_id])
    ride = Ride.find_by(id: params[:ride_id])
    price = ride[:price]
    distance = user.rides.find_by(id: params[:ride_id])[:realtime_km]
    driver_id = ride.driver[:id]
    project_id = ride.project[:id]

    contribution_amount = price*distance
    user.update_attribute(:unbound_contributions, contribution_amount)
    user.contributions.update_attributes(amount: contribution_amount, project_id: project_id)
    user.rides.find_by(id: ride.id).update_attribute(:is_paid, true)
    render json: {:status => 200}
  end

  def destroy
    # if driver confirmed a ride then add a new passenger, if not then just delete the request
    user = User.find_by(id: params[:user_id])
    ride = Ride.find_by(id: params[:ride_id])
    passenger = User.find_by(id: params[:passenger_id])

    request = ride.requests.find_by(ride_id: ride.id, passenger_id: passenger.id)
    if params[:confirmed] == true
      passenger.rides_as_passenger.create!(departure_place: params[:departure_place], destination: params[:destination],
                                           meeting_point: ride[:meeting_point], departure_time: ride[:departure_time])
    end
    request.destroy
    render json: {:status => 200}
  end

end
