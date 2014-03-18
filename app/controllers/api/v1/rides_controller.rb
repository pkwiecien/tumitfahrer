class Api::V1::RidesController < ApiController
  respond_to :json, :xml
  # before_action :restrict_access, only: [:index, :create]
  before_filter :load_parent

  def index

    if params.has_key?(:user_id)
      # mapping for url : /api/version/users/1/rides
      @rides = @parent.rides
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
      current_user = User.find_by(id: params[:user_id])
      @ride = current_user.rides.create!(ride_params)
      current_user.relationships.find_by(ride_id: @ride.id).update_attribute(:is_driving, true)

      @project = Project.find_by(id: params[:ride][:project_id])
      logger.debug "Found project: #{@project}"
      unless @project.nil?
        @ride.project = @project
      end

      if @ride.save
        logger.debug "Ride saved!!!"
        render json: {:status => 200}
      else
        render json: {:status => 400}
      end
    else
      render json: {:status => 400}
    end
  end

  private

  def restrict_access
    authenticate_or_request_with_http_token do |key, options|
      User.exists?(api_key: key)
    end
  end

  def ride_params
    params.require(:ride).permit(:departure_place, :destination, :price, :free_seats, :meeting_point, :departure_time)
  end

  def load_parent
    @parent = User.find_by(id: params[:user_id])
  end

end
