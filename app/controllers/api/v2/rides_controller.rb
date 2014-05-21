class Api::V2::RidesController < ApiController
  respond_to :json, :xml, :html
  before_filter :check_format, only: [:show]
  #before_filter :restrict_access, only: [:index, :create]

  # GET /api/v2/rides
  def index
    if params.has_key?(:page)

      campus_rides = Ride.where(ride_type: 0).order(departure_time: :desc).offset(params[:page].to_i*6).limit(6)
      activity_rides = Ride.where(ride_type: 1).order(departure_time: :desc).offset(params[:page].to_i*6).limit(6)
      ride_requests = Ride.where(ride_type: 2).order(departure_time: :desc).offset(params[:page].to_i*6).limit(6)
      temp_rides = campus_rides + activity_rides + ride_requests

      @rides = []
      temp_rides.each do |r|
        if !r.driver.nil?
          @rides.append(r)
        end
      end
      respond_with @rides, status: :ok
    else
      @rides = Ride.rides_of_drivers
      respond_with @rides, status: :ok
      # todo: potentially check if there are rides at all, and if not then respond with status code :no_content
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

  # POST /api/v2/rides/
  def create
    begin
      # TODO: potentially replace user_id with token
      current_user = User.find_by(api_key: request.headers[:apiKey])
      return render json: {:ride => nil}, status: :bad_request if current_user.nil?

      @ride = current_user.rides_as_driver.create!(ride_params)

      unless @ride.nil?
        unless params[:ride][:project_id].nil?
          @ride.assign_project(Project.find_by(id: params[:ride][:project_id]))
        end
        logger.debug "Current user #{current_user} and ride: #{@ride}"

        logger.debug "Found: #{current_user.relationships.find_by(ride_id: @ride.id)}"

        current_user.relationships.find_by(ride_id: @ride.id).update_attribute(:is_driving, true)
        logger.debug "updated"

        # update distance and duration
        # @ride.update_attributes(distance: distance(@ride[:departure_place], @ride[:destination]))
        # @ride.update_attributes(duration: duration(@ride[:departure_place], @ride[:destination]))

        logger.debug "returning #{@ride}"

        respond_with @ride, status: :created
      else
        render json: {:ride => nil}, status: :bad_request
      end
    rescue
      return respond_with json: {:ride => nil}, status: :bad_request
    end
  end

  def destroy
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
    params.require(:ride).permit(:departure_place, :destination, :departure_time, :free_seats, :meeting_point, :ride_type)
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

