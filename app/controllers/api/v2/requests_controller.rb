class Api::V2::RequestsController < ApiController
  respond_to :xml, :json

  # GET /api/v2/rides/1/requests
  def index
    ride = Ride.find_by(id: params[:ride_id])
    return respond_with ride: [], status: :not_found if ride.nil?
    requests = ride.requests
    respond_with requests: requests, status: :ok
  end

  # GET /api/v2/users/1/requests
  def get_user_requests
    user = User.find_by(id: params[:user_id])
    return respond_with :requests => [], :status => :not_found if user.nil?

    respond_with Request.where(ride_id: user.requested_rides), status: :ok
  end

  # POST /api/v2/rides/:ride_id/requests
  def create
    ride = Ride.find_by(id: params[:ride_id])
    return render json: {request: []}, status: :bad_request if ride.requests.find_by(passenger_id: params[:passenger_id]) != nil

    @new_request = ride.requests.create!(request_params)

    unless @new_request.nil?
      #Added by Behroz - Send notification to driver that user wants to join the ride - 16-06-2014 - Start
      Notification.user_join(params[:ride_id])
      #Added by Behroz - 16-06-2014 - End

	    render json: {request: @new_request}, status: :created
    else
      render json: {request: []}, status: :bad_request
    end
  end

  # PUT /api/v2/rides/:ride_id/requests?passenger_id=X
  def update
    
    ride = Ride.find_by(id: params[:ride_id])
    passenger = User.find_by(id: params[:passenger_id])
    return render json: {status: :not_found} if ride.nil? || passenger.nil?
    
    ride.accept_ride_request ride.ride_owner.id, passenger.id, params[:confirmed].to_i

    #Added by Behroz - Send notification to passenger since driver has accepted the ride - 16-06-2014 - Start
    Notification.accept_request(passenger, ride, ride[:departure_time])
    #Added by Behroz - Send notification to passenger since driver has accepted the ride - 16-06-2014 - End
    
    respond_to do |format|
      format.xml { render xml: {:status => :ok, :message => "request handled successfully"} }
      format.any { render json: {:status => :ok, :message => "request handled successfully"} }
    end
  end

  # DELETE /api/v2/rides/:ride_id/requests/:id
  def destroy
    ride = Ride.find_by(id: params[:ride_id])
    return render json: {status: :not_found, message: "ride not found"} if ride.nil?

    #Changed by Behroz - When request is declined by driver. We need to insert the notification. Start 18-06-2014
    request = Request.find_by(id: params[:id])
    Notification.decline_request(request.ride_id, request.passenger_id)
    #Changed by Behroz - When request is declined by driver. We need to insert the notifacation. End 18-06-2014

    ride.remove_ride_request params[:id]

    respond_to do |format|
      format.xml { render xml: {:status => :ok} }
      format.any { render json: {:status => :ok} }
    end
  end

  private

  def request_params
    params.require(:request).permit(:passenger_id)
  end

end
