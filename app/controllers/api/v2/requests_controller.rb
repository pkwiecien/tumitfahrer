class Api::V2::RequestsController < ApiController
  respond_to :xml, :json

  # GET /api/v1/rides/1/requests
  def index
    ride = Ride.find_by(id: params[:ride_id])
    return respond_with ride: [], status: :not_found if ride.nil?
    requests = ride.requests
    respond_with requests: requests, status: :ok
  end

  # POST /api/v2/rides/:ride_id/requests
  def create
    ride = Ride.find_by(id: params[:ride_id])
    @new_request = ride.requests.create!(request_params)

    unless @new_request.nil?
      logger.debug "Created ride request for ride with id: #{ride.id} adnd reuqest id: #{@new_request.id}"
      render json: {status: :created, request: @new_request}
    else
      render json: {status: :bad_request}
    end
  end

  # PUT /api/v1/rides/:ride_id/requests?passenger_id=X&departure_place=Y&destination=Z
  def update
    # if driver confirmed a ride then add a new passenger, if not then just delete the request
    ride = Ride.find_by(id: params[:ride_id])
    passenger = User.find_by(id: params[:passenger_id])
    if ride.nil? || passenger.nil?
      respond_to do |format|
        format.xml { render xml: {:status => :not_found} }
        format.any { render json: {:status => :not_found} }
      end
    end

    request = ride.requests.find_by(ride_id: ride.id, passenger_id: passenger.id)
    if params[:id] && params[:confirmed] == true
      new_ride = passenger.rides_as_passenger.create!(departure_place: params[:departure_place], destination: params[:destination],
                                                      meeting_point: ride[:meeting_point], departure_time: ride[:departure_time],
                                                      free_seats: ride[:free_seats])
      Relationship.find_by(ride_id: new_ride.id).update_attributes(driver_ride_id: ride.id)
      # TODO: send push notification if request was confirmed
    end
    request.destroy

    respond_to do |format|
      format.xml { render xml: {:status => :ok} }
      format.any { render json: {:status => :ok} }
    end
  end

  def destroy
    begin
      request = Request.find_by(id: params[:id]).destroy
      respond_to do |format|
        format.xml { render xml: {:status => :ok} }
        format.any { render json: {:status => :ok} }
      end
    rescue
      respond_to do |format|
        format.xml { render xml: {:status => :not_found} }
        format.any { render json: {:status => :not_found} }
      end
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
    params.require(:request).permit(:requested_from, :request_to, :passenger_id)
  end

end
