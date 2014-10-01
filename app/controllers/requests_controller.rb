class RequestsController < ApplicationController
  before_action :signed_in_user

  def index
    ride = Ride.find_by(id: params[:ride_id])

    if ride.nil?
      flash[:error] = "No request found for the ride."
    else
      @requests = ride.requests
    end
    redirect_to request.referer
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
    ride = Ride.find_by(id: params[:ride_id])
    if ride.requests.find_by(passenger_id: params[:passenger_id]) != nil
      flash[:error] = "You have already request pending for this ride."
    else
      @new_request = ride.create_ride_request params[:passenger_id]
      unless @new_request
        #Added by Behroz - Send notification to driver that user wants to join the ride - 16-06-2014 - Start
        Notification.user_join(params[:ride_id])
        #Added by Behroz - 16-06-2014 - End
      end
    end

    redirect_to request.referer
  end

  # PUT /api/v2/rides/:ride_id/requests/:id?passenger_id=X
  def update

    ride = Ride.find_by(id: params[:ride_id])
    passenger = User.find_by(id: params[:passenger_id])

    ride.accept_ride_request ride.ride_owner.id, passenger.id, params[:confirmed].to_i

    #Added by Behroz - Send notification to passenger since driver has accepted the ride - 16-06-2014 - Start
    Notification.accept_request(passenger.id, ride.id, ride[:departure_time])
    #Added by Behroz - Send notification to passenger since driver has accepted the ride - 16-06-2014 - End

    redirect_to request.referer
  end

  # DELETE /api/v2/rides/:ride_id/requests/:id
  def destroy
    ride = Ride.find_by(id: params[:ride_id])

    #Changed by Behroz - When request is declined by driver. We need to insert the notification. Start 18-06-2014
    request = Request.find_by(id: params[:id])
    Notification.decline_request(request.ride_id, request.passenger_id)
    #Changed by Behroz - When request is declined by driver. We need to insert the notifacation. End 18-06-2014

    ride.remove_ride_request params[:id]

    redirect_to request.referer
  end
end
