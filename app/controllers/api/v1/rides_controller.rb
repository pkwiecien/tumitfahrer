class Api::V1::RidesController < ApiController
  respond_to :json, :xml
  # before_action :restrict_access, only: [:index, :create]
  before_filter :load_parent

  def index

    if params.has_key?(:user_id)
      # mapping for url : /api/version/users/1/rides
      @rides = @parent.rides.all
    else
      # mapping for url: /api/version/rides
      @rides = Ride.all
    end

    if @rides.nil?
      render json: {:message => "There are no rides"}
    else
      respond_to do |format|
        format.json { render json: @rides }
        format.xml { render xml: @rides }
      end
    end
  end

  def show
    @ride = Ride.find(params[:id])
    respond_to do |format|
      format.json { render json: @ride }
      format.xml { render xml: @ride }
    end
  end

  def create
    current_user = User.find_by(api_key: request.headers['apiKey'])
    logger.debug request.headers['apiKey']
    @ride = current_user.rides.build(ride_params)
    if @ride.save
      render json: {:result => "1"}
    else
      render json: {:result => "0"}
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

  def load_parent
    @parent = User.find_by(id: params[:user_id])
  end

end
