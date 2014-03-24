class Api::V1::RidesController < ApiController
  respond_to :json, :xml
  # before_action :restrict_access, only: [:index, :create]
  before_filter :load_parent

  def index

    if params.has_key?(:user_id)
      # mapping for url : /api/version/users/1/rides
      @rides = @parent.rides_as_driver + @parent.rides_as_passenger
      if params.has_key?(:is_paid)
        @rides = @rides.where(is_paid: params[:is_paid])
      end
    else
      # mapping for url: /api/version/rides
      @rides = Ride.all
    end

    @rides.each do |r|
      unless r.driver.nil?
        r.update_attribute(:free_seats, r.driver.rides.find_by(id: r.id).free_seats)
      end
    end

    @rides.each do |r|
      logger.debug "Returning: #{r.to_s}"
    end

    respond_with @rides
  end

  def show
    @ride = Ride.find_by(id: params[:id])
    if @ride.nil?
      respond_with :status => 400
    else
      respond_with @ride
    end

  end

  def create
    if params.has_key?(:user_id)
      current_user = User.find_by(id: params[:user_id])
      @ride = current_user.rides_as_driver.create!(ride_params)
      unless params[:ride][:project_id].nil?
        @ride.assign_project(Project.find_by(id: params[:ride][:project_id]))
      end
      current_user.relationships.find_by(ride_id: @ride.id).update_attribute(:is_driving, true)

      if @ride.save
        respond_with :status => 200
      else
        respond_with :status => 400
      end

      # update distance and duration after returning to the client
      @ride.update_attributes(distance: distance(@ride[:departure_place], @ride[:destination]))
      @ride.update_attributes(duration: duration(@ride[:departure_place], @ride[:destination]))
    else
      respond_with :status => 400
    end
  end

  def update
    if params.has_key?(:user_id)
      current_user = User.find_by(id: params[:user_id])
      requested_ride = current_user.rides_as_driver.find_by(id: params[:id])
      unless requested_ride.nil?
        requested_ride.update_attributes(ride_params)
        respond_with :status => 200
      end
    else
      respond_with :status => 400
    end
  end

  def destroy
    if params.has_key?(:user_id)
      current_user = User.find_by(id: params[:user_id])
      ride = current_user.rides_as_driver.find_by(id: params[:id])
      project = Project.find_by(ride_id: ride.id)
      unless ride.nil?
        ride.destroy!
        unless project.nil?
          project[:ride_id] = nil
        end
        respond_with :status => 200
      else
        respond_with :status => 400
      end
    else
      respond_with :status => 400
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

  def distance(start_point, end_point)
    result = prepare_url(start_point, end_point)
    return result["routes"].first["legs"].first["distance"]["value"]/1000
  end

  def duration(start_point, end_point)
    result = prepare_url(start_point, end_point)
    return result["routes"].first["legs"].first["duration"]["value"]/60
  end

  def prepare_url(start_point, end_point)
    url = URI.parse(URI.encode("http://maps.googleapis.com/maps/api/directions/json?origin=\"#{start_point}\"&destination=\"#{end_point}\"&sensor=false"))
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) { |http|
      http.request(req)
    }
    return JSON.parse(res.body)
  end

end
