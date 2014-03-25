class Api::V1::RequestsController < ApiController
  respond_to :xml, :json

  # GET /api/v1/users/1/requests
  def index
    user = User.find_by(id: params[:user_id])
    return respond_with contributions: [], status: :bad_request if user.nil?
    contributions = user.contributions
    respond_with contributions: contributions, status: :ok
  end

  # todo: refactor
  # POST /api/v1/rides/:ride_id/requests
  def create
    if params.has_key?(:unbound_contributions)
      user = User.find_by(id: params[:user_id])
      ride = Ride.find_by(id: params[:ride_id])
      price = ride[:price]
      distance = user.rides.find_by(id: params[:ride_id])[:realtime_km]
      project_id = ride.project[:id]

      contribution_amount = price*distance
      user.update_attribute(:unbound_contributions, contribution_amount)
      user.contributions.update_attributes(amount: contribution_amount, project_id: project_id)
      user.rides.find_by(id: ride.id).update_attribute(:is_paid, true)
      render json: {:status => 200}
    else
      ride = Ride.find_by(id: params[:ride_id])
      new_ride = ride.requests.create!(passenger_id: params[:user_id], requested_from: params[:requested_from],
                                       request_to: params[:requested_to])
      unless new_ride.nil?
        respond_with ride: new_ride, anfrage: true, status: :ok
      else
        respond_with ride: new_ride, anfrage: false, status: :bad_request
      end
    end
  end

  # PUT /api/v1/rides/:ride_id/requests?passenger_id=X&departure_place=Y&destination=Z
  def update
    # if driver confirmed a ride then add a new passenger, if not then just delete the request
    ride = Ride.find_by(id: params[:ride_id])
    passenger = User.find_by(id: params[:passenger_id])
    if ride.nil? || passenger.nil?
      respond_to do |format|
        format.xml { render xml: {:status => :bad_request} }
        format.any { render json: {:status => :bad_request} }
      end
    end

    request = ride.requests.find_by(ride_id: ride.id, passenger_id: passenger.id)
    if params[:id] && params[:confirmed] == true
      new_ride = passenger.rides_as_passenger.create!(departure_place: params[:departure_place], destination: params[:destination],
                                                      meeting_point: ride[:meeting_point], departure_time: ride[:departure_time],
                                                      free_seats: ride[:free_seats])
      Relationship.find_by(ride_id: new_ride.id).update_attributes(driver_ride_id: ride.id)
      unless new_ride.nil?
        send_android_push(:akzeptierung, new_ride)
      end
    else
      send_android_push(:absage, new_ride)
    end
    request.destroy

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

end
