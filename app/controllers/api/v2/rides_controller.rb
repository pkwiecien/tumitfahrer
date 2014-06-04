class Api::V2::RidesController < ApiController
  respond_to :json, :xml, :html
  before_filter :check_format, only: [:show]
  #before_filter :restrict_access, only: [:index, :create]

  @@num_page_results = 10

  # GET /api/v2/rides
  def index
    page = 0

    if params.has_key?(:page)
      page = params[:page].to_i
    end

    campus_rides = Ride.where(ride_type: 0).order(departure_time: :desc).joins(:relationships)
    .where(:relationships => {is_driving: true}).offset(page*@@num_page_results).limit(@@num_page_results)

    activity_rides = Ride.where(ride_type: 1).order(departure_time: :desc).joins(:relationships)
    .where(:relationships => {is_driving: true}).offset(page*@@num_page_results).
        limit(@@num_page_results)

    @rides = campus_rides + activity_rides
    unless @rides.nil?
      respond_with @rides, status: :ok
    else
      respond_with :rides => [], status: :no_content
    end

  end

  # GET api/v2/users/:user_id/rides
  # optional @param is_paid=true/false - get rides of the user that are paid or not
  def get_user_rides
    user = User.find_by(id: params[:user_id])
    return respond_with :rides => [], :status => :not_found if user.nil?

    if params.has_key?(:driver)
      @rides = user.rides_as_driver
    elsif params.has_key?(:passenger)
      @rides = user.rides_as_passenger
    else
      @rides = user.rides_as_driver + user.rides_as_passenger
    end

    if params.has_key?(:is_paid)
      @rides = @rides.where(is_paid: params[:is_paid])
    end
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
    begin
      current_user_db = User.find_by(id: params[:user_id])
      current_user = User.find_by(api_key: request.headers[:apiKey])
      return render json: {:ride => nil}, status: :bad_request if current_user.nil? || current_user != current_user_db

      @ride = Ride.create_ride_by_owner ride_params, current_user

      unless @ride.nil?
        # update distance and duration
        # @ride.update_attributes(distance: distance(@ride[:departure_place], @ride[:destination]))
        # @ride.update_attributes(duration: duration(@ride[:departure_place], @ride[:destination]))
        respond_with @ride, status: :created
      else
        render json: {:ride => nil}, status: :bad_request
      end
    rescue
      return respond_with json: {:ride => nil}, status: :bad_request
    end
  end

  def destroy
    ride = Ride.find_by(id: params[:id])

    begin
      ride = Ride.find_by(id: params[:id]).destroy

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

  def restrict_access
    authenticate_or_request_with_http_token do |key, options|
      User.exists?(api_key: key)
    end
  end

  def ride_params
    params.require(:ride).permit(:departure_place, :destination, :departure_time, :free_seats, :meeting_point, :ride_type, :is_driving)
  end

  # get distance of the ride from google api
  def distance(start_point, end_point)
    result = prepare_url(start_point, end_point)
    return result["routes"].first["legs"].first["distance"]["value"]/1000
  end

  # get duration of the ride from google api
  def duration(start_point, end_point)
    result = prepare_url(start_point, end_point)
    return result["routes"].first["legs"].first["duration"]["value"]/60
  end

  # call google api
  def prepare_url(start_point, end_point)
    url = URI.parse(URI.encode("http://maps.googleapis.com/maps/api/directions/json?origin=\"#{start_point}\"&destination=\"#{end_point}\"&sensor=false"))
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) { |http|
      http.request(req)
    }
    return JSON.parse(res.body)
  end

  def check_format
    puts request.format.inspect
    if request.format.to_s == "application/json"
      puts "hello"
    else
      puts "world"
    end
  end

end

