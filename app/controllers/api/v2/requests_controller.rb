class Api::V2::RequestsController < ApiController
  respond_to :xml, :json

  # GET /api/v2/rides/:ride_id/requests
  def index
    user_from_api_key = User.find_by(api_key: request.headers[:apiKey])
    return render json: {requests: [], message: "Access denied"}, status: :unauthorized if user_from_api_key.nil?

    ride = Ride.find_by(id: params[:ride_id])
    return respond_with ride: [], status: :not_found if ride.nil?
    requests = ride.requests
    respond_with requests: requests, status: :ok
  end

  # GET /api/v2/users/:user_id/requests/:id
  def get_user_requests
    user_from_api_key = User.find_by(api_key: request.headers[:apiKey])
    return render json: {request: [], message: "Access denied"}, status: :unauthorized if user_from_api_key.nil?

    user = User.find_by(id: params[:user_id])
    return respond_with :requests => [], :status => :not_found if user.nil?

    respond_with Request.where(ride_id: user.requested_rides), status: :ok
  end

  # POST /api/v2/rides/:ride_id/requests
  def create
    user_from_api_key = User.find_by(api_key: request.headers[:apiKey])
    return render json: {request: [], message: "Access denied"}, status: :unauthorized if user_from_api_key.nil?

    ride = Ride.find_by(id: params[:ride_id])
    return render json: {request: []}, status: :bad_request if ride.requests.find_by(passenger_id: params[:passenger_id]) != nil

    @new_request = ride.create_ride_request params[:passenger_id]

    unless @new_request.nil?
      render json: {request: @new_request}, status: :created
    else
      render json: {request: []}, status: :bad_request
    end
  end

  # PUT /api/v2/rides/:ride_id/requests/:id?passenger_id=X
  def update
    user_from_api_key = User.find_by(api_key: request.headers[:apiKey])
    return render json: {message: "Access denied"}, status: :unauthorized if user_from_api_key.nil?

    ride = Ride.find_by(id: params[:ride_id])
    passenger = User.find_by(id: params[:passenger_id])
    return render json: {status: :not_found} if ride.nil? || passenger.nil?

    ride.accept_ride_request ride.ride_owner.id, passenger.id, params[:confirmed].to_i
    # TODO: send push notification if request was confirmed or rejected

    respond_to do |format|
      format.xml { render xml: {:message => "Request handled successfully"}, :status => :ok }
      format.any { render json: {:message => "Request handled successfully"}, :status => :ok }
    end
  end

  # DELETE /api/v2/rides/:ride_id/requests/:id
  def destroy
    user_from_api_key = User.find_by(api_key: request.headers[:apiKey])
    return render json: {message: "Access denied"}, status: :unauthorized if user_from_api_key.nil?

    ride = Ride.find_by(id: params[:ride_id])
    return render json: {message: "Ride not found"}, status: :not_found if ride.nil?

    ride.remove_ride_request params[:id]

    respond_to do |format|
      format.xml { render xml: {message: "Request successfully deleted"}, :status => :ok }
      format.any { render json: {message: "Request successfully deleted"}, :status => :ok }
    end

  end


  private


end
