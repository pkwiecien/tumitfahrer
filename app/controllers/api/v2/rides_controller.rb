class Api::V2::RidesController < ApiController
  respond_to :json, :xml, :html
  #before_filter :restrict_access, only: [:index, :create]

  @@num_page_results = 10

  # GET /api/v2/rides
  def index

    if params.has_key?(:from_date)
      get_rides_from_date  Time.zone.parse(params[:from_date]), params[:ride_type].to_i
    else
      page = 0

      if params.has_key?(:page)
        page = params[:page].to_i
      end

      campus_rides = Ride.where("ride_type = ? AND departure_time > ?", 0, Time.now).order(departure_time: :desc).offset(page*@@num_page_results).limit(@@num_page_results)
      activity_rides = Ride.where("ride_type = ? AND departure_time > ?", 1, Time.now).order(departure_time: :desc).offset(page*@@num_page_results).
          limit(@@num_page_results)

      @rides = campus_rides + activity_rides
      unless @rides.nil?
        respond_with @rides, status: :ok
      else
        respond_with :rides => [], status: :no_content
      end
    end
  end

  def get_rides_from_date from_date, ride_type
    @rides = Ride.where("ride_type = ? AND updated_at > ? ", ride_type, from_date)
    @rides.each do |r|
      logger.debug "ride with id #{r.id} , updated_at : #{r.updated_at} , from date: #{from_date}, comparison: #{from_date>r.updated_at}"
    end
    respond_with @rides, status: :ok
  end

  # GET api/v2/rides/ids
  def get_ids_existing_rides

    ride_ids = Ride.select(:id).map(&:id)
    respond_to do |format|
      format.xml { render xml: {ids: ride_ids}, :status => :ok }
      format.json { render json: {ids: ride_ids}, :status => :ok }
    end
  end

  # GET api/v2/users/:user_id/rides
  # optional @param is_paid=true/false - get rides of the user that are paid or not
  def get_user_rides
    user = User.find_by(id: params[:user_id])
    current_user = User.find_by(api_key: request.headers[:apiKey])
    return render json: {:rides => [], message: "Access denied"}, status: :unauthorized if current_user.nil? || user.id != current_user.id

    if params.has_key?(:past)
      return get_past_rides user
    elsif params.has_key?(:driver)
      @rides = user.rides_as_driver
    elsif params.has_key?(:passenger)
      @rides = user.rides_as_passenger
    else
      @rides = user.all_rides
    end

    if params.has_key?(:is_paid)
      @rides = @rides.where(is_paid: params[:is_paid])
    end
    respond_with @rides, status: :ok
  end

  #GET /api/v2/rides?past
  def get_past_rides user
    @rides = user.rides.where("departure_time < ?", Time.now)
    respond_with @rides, status: :ok
  end

  # GET /api/v2/rides/:id
  def show

    @ride = Ride.find_by(:id => params[:id])
    if @ride.nil?
      @ride = {:ride => nil}
      respond_with @ride, status: :not_found
    else
      respond_with @ride, status: :ok
    end
  end

  # POST /api/v2/users/11/rides/
  def create
    current_user_db = User.find_by(id: params[:user_id])
    current_user = User.find_by(api_key: request.headers[:apiKey])
    return render json: {:ride => []}, status: :unauthorized if current_user.nil? || current_user != current_user_db

    regular_ride_dates = params[:ride][:repeat_dates]
    if !regular_ride_dates.nil? && regular_ride_dates.count > 0
      @rides = Ride.create_regular_rides regular_ride_dates, ride_params, current_user
      render json: @rides, each_serializer: RideSerializer, status: :created
    else
      @ride = Ride.create_ride_by_owner ride_params, current_user, params[:ride][:is_driving].to_i

      unless @ride.nil?
        respond_with @ride, status: :created
      else
        render json: {:ride => nil}, status: :bad_request
      end

    end
  end

  # UPDATE /api/v2/users/11/rides/:ride_id?removed_passenger=id
  # UPDATE /api/v2/users/11/rides/:ride_id?added_passenger=id
  def update
    user_from_api_key = User.find_by(api_key: request.headers[:apiKey])
    return render json: {:ride => [], message: "Access denied"}, status: :unauthorized if user_from_api_key.nil?

    if params.has_key?(:removed_passenger) # update ride -> remove passenger
      ride = Ride.find_by(:id => params[:id])
      return render json: {status: :not_found, message: "could not delete passenger"} if ride.nil?

      ride.remove_passenger ride.ride_owner.id, params[:removed_passenger]
      return render json: {status: :ok, message: "passenger deleted"}
    elsif params.has_key?(:added_passenger)
      ride = Ride.find_by(:id => params[:id])
      return render json: {status: :not_found, message: "could not add passenger"} if ride.nil?

      ride.add_passenger params[:added_passenger]
      return render json: {status: :ok, message: "passenger added"}
    else
      @user = User.find_by(id: params[:user_id])
      return respond_with status: :not_found, message: "Could not retrieve the user" if @user.nil?
      @ride = Ride.find_by(id: params[:id])
      return respond_with status: :not_found, message: "Could not retrieve the ride" if @ride.nil?
      # here we need to do it manually, cause two params should be int

      @ride.update_attributes!(meeting_point: params[:ride][:meeting_point], departure_place: params[:ride][:departure_place],
                               destination: params[:ride][:destination], free_seats: params[:ride][:free_seats].to_i,
                               departure_time: params[:ride][:departure_time], ride_type: params[:ride][:ride_type].to_i, car: params[:ride][:car],
                               departure_latitude: params[:ride][:departure_latitude].to_f, departure_longitude: params[:ride][:departure_longitude].to_f,
                               destination_latitude: params[:ride][:destination_latitude].to_f, destination_longitude: params[:ride][:destination_longitude].to_f)
      respond_with @ride, status: :ok
    end

  end

  def destroy

    user_from_api_key = User.find_by(api_key: request.headers[:apiKey])
    return render json: {message: "Access denied"}, status: :unauthorized if user_from_api_key.nil?

    if params.has_key?(:regular_ride_id)
      rides = Ride.where(regular_ride_id: params[:regular_ride_id])
      #Added by Behroz - insert the notification - 16-06-2014 - Start
      Notification.cancel_ride(params[:id], params[:user_id])
      #Added by Behroz - insert the notification - 16-06-2014 - End
      rides.destroy_all
    else
      ride = Ride.find_by(id: params[:id])
      return render json: {message: "Could not destroy a ride"}, status: :not_found if ride.nil?

      #Added by Behroz - insert the notification - 16-06-2014 - Start
      Notification.cancel_ride(params[:id], params[:user_id])
      #Added by Behroz - insert the notification - 16-06-2014 - End

      ride.destroy
    end

    reason = params[:reason]
    # TODO send push notification with reason
    respond_to do |format|
      format.xml { render xml: {message: "Ride was successfully deleted"}, :status => :ok }
      format.any { render json: {message: "Ride was successfully deleted"}, :status => :ok }
    end
  end

  private

  def restrict_access
    authenticate_or_request_with_http_token do |key, options|
      User.exists?(api_key: key)
    end
  end

  def ride_params
    params.require(:ride).permit(:departure_place, :destination, :departure_time, :free_seats,
                                 :meeting_point, :ride_type, :is_driving, :car, :departure_latitude,
                                 :departure_longitude, :destination_latitude, :destination_longitude, :repeat_dates)
  end

end

