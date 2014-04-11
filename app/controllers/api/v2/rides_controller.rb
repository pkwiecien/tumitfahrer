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
    current_user = User.find_by(api_key: request.headers['apiKey'])
    logger.debug request.headers['apiKey']
    @ride = current_user.rides.build(ride_params)
    if @ride.save
      respond_with @ride, status: :created
    else
      respond_with @ride, status: :bad_request
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
end
