class Api::V2::RidesController < ApiController
  respond_to :json, :xml
  # before_action :restrict_access, only: [:index, :create]

  # GET /api/v1/rides
  def index
    @rides = Ride.all
    respond_with @rides, status: :ok
    # todo: potentially check if there are rides at all, and if not then respond with status code :no_content
  end

  # GET /api/v1/rides/:id
  def show
    @ride = Ride.find(params[:id])
    if @ride.nil?
      respond_with @ride, status: :not_found
    else
      respond_with @ride, status: :ok
    end
  end

  # POST /api/v1/rides/
  def create
    begin
      current_user = User.find_by(api_key: "aI_pzMk34dwM8_KpWsVQDw")
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
        #

        logger.debug "returning #{@ride}"

        respond_with @ride, status: :created
      else
        render json: {:ride => nil}, status: :bad_request
      end
    rescue
      return render json: {:ride => nil}, status: :bad_request
    end
  end

  private

  def restrict_access
    authenticate_or_request_with_http_token do |key, options|
      User.exists?(api_key: key)
    end
  end

  def ride_params
    params.require(:ride).permit(:departure_place, :destination, :departure_time, :free_seats, :meeting_point)
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

end

