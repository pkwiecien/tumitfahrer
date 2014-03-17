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
    if params.has_key?(:user_id)
      current_user = User.find_by(user_id: params[:user_id])
      @ride = current_user.rides.build(ride_params)
      @project = Project.find_by(id: params[:project_id])
      logger.debug "Found project: #{project}"
      unless @project.nil?
        @ride.project = @project
      end

      if @ride.save
        render json: {:result => "1"}
      else
        render json: {:result => "0"}
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
    params.require(:ride).permit(:departure_place, :destination, :departure_time, :price, :free_seats, :meeting_point)
  end

  def load_parent
    @parent = User.find_by(id: params[:user_id])
  end

end
