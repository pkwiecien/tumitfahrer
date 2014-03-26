class Api::V1::RidesController < ApiController
  respond_to :json, :xml
  # before_action :restrict_access, only: [:index, :create]

  # GET /api/v1/rides
  def index
    @rides = Ride.all
    respond_with @rides, status: :ok
  end

  # GET api/v1/users/:user_id/rides
  # optional @param is_paid=true/false - get rides of the user that are paid or not
  def get_user_rides
    user = User.find_by(id: params[:user_id])
    return respond_with :rides => [], :status => :not_found if user.nil?

    @rides = user.rides_as_driver + user.rides_as_passenger
    if params.has_key?(:is_paid)
      @rides = @rides.where(is_paid: params[:is_paid])
    end
    respond_with @rides, status: :ok
  end

  # GET /api/v1/rides/:id
  def show
    @ride = Ride.find_by(id: params[:id])
    if @ride.nil?
      respond_with @ride => [], :status => :not_found
    else
      respond_with @ride, status: :ok
    end
  end

  # POST /api/v1/users/:user_id/rides
  def create
    begin
      current_user = User.find_by(id: params[:user_id])
      @ride = current_user.rides_as_driver.create!(ride_params)
      unless params[:ride][:project_id].nil?
        @ride.assign_project(Project.find_by(id: params[:ride][:project_id]))
      end
      current_user.relationships.find_by(ride_id: @ride.id).update_attribute(:is_driving, true)

      # update distance and duration
      @ride.update_attributes(distance: distance(@ride[:departure_place], @ride[:destination]))
      @ride.update_attributes(duration: duration(@ride[:departure_place], @ride[:destination]))

      unless @ride.nil?
        respond_with ride: @ride, status: :created
      else
        respond_with ride: {}, status: :bad_request
      end
    rescue
      respond_with ride: {}, status: :bad_request
    end
  end

  # PUT /api/v1/users/:user_id/rides
  def update
    begin
      current_user = User.find_by(id: params[:user_id])
      requested_ride = current_user.rides_as_driver.find_by(id: params[:id])
      unless requested_ride.nil?
        requested_ride.update_attributes(ride_params)
        respond_to do |format|
          format.xml { render xml: {:status => :ok} }
          format.any { render json: {:status => :ok} }
        end
      end
    rescue
      respond_to do |format|
        format.xml { render xml: {:status => :bad_request} }
        format.any { render json: {:status => :bad_request} }
      end
    end
  end

  # todo: refactor
  # DELETE /api/v1/users/:user_id/rides/2
  def destroy
    begin
      current_user = User.find_by(id: params[:user_id])
      ride = current_user.rides_as_driver.find_by(id: params[:id])
      project = Project.find_by(ride_id: ride.id)
      unless ride.nil?
        ride.destroy!
        unless project.nil?
          project[:ride_id] = nil
        end
        respond_to do |format|
          format.xml { render xml: {:status => :ok} }
          format.any { render json: {:status => :ok} }
        end
      else
        respond_to do |format|
          format.xml { render xml: {:status => :bad_request} }
          format.any { render json: {:status => :bad_request} }
        end
      end
    rescue
      respond_to do |format|
        format.xml { render xml: {:status => :bad_request} }
        format.any { render json: {:status => :bad_request} }
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
    params.require(:ride).permit(:departure_place, :destination, :price, :free_seats, :meeting_point, :departure_time)
  end

  def update_ride_params
    params.require(:ride).permit(:departure_place, :destination, :price, :free_seats, :meeting_point, :departure_time,
                                 :project_id, :is_finished)
  end

  def load_parent
    @parent = User.find_by(id: params[:user_id])
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
