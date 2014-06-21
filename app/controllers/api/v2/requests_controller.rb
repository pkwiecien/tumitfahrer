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
    return render json: {status: :bad_request, request: []} if ride.requests.find_by(passenger_id: params[:passenger_id]) != nil

    @new_request = ride.requests.create!(request_params)

    unless @new_request.nil?
      render json: {status: :created, request: @new_request}
    else
      render json: {status: :bad_request}
    end
  end

  # PUT /api/v2/rides/:ride_id/requests?passenger_id=X
  def update

    ride = Ride.find_by(id: params[:ride_id])
    passenger = User.find_by(id: params[:passenger_id])
    return render json: {status: :not_found} if ride.nil? || passenger.nil?

    ride.accept_ride_request ride.ride_owner.id, passenger.id, params[:confirmed].to_i
    # TODO: send push notification if request was confirmed or rejected

    respond_to do |format|
      format.xml { render xml: {:status => :ok, :message => "request handled successfully"} }
      format.any { render json: {:status => :ok, :message => "request handled successfully"} }
    end
  end

  # DELETE /api/v2/rides/:ride_id/requests/:id
  def destroy
    ride = Ride.find_by(id: params[:ride_id])
    return render json: {status: :not_found, message: "ride not found"} if ride.nil?

    ride.remove_ride_request params[:id]

    respond_to do |format|
      format.xml { render xml: {:status => :ok} }
      format.any { render json: {:status => :ok} }
    end

  end


  private

  def send_android_push(type, new_ride)
    user = new_ride.users.first
    devices = user.devices.where(platform: "android")
    registration_ids = []
    devices.each do |d|
      registration_ids.append(d[:token])
    end

    options = {}
    options[:type] = type
    options[:fahrt_id] = new_ride[:id]
    options[:fahrer] = new_ride.driver.full_name
    options[:ziel] = new_ride[:destination]

    logger.debug "Sending push notification with reg_ids : #{registration_ids} and options: #{options}"
    response = GcmUtils.send_android_push_notifications(registration_ids, options)
    logger.debug "Response: #{response}"
  end

  def request_params
    params.require(:request).permit(:passenger_id)
  end

end
