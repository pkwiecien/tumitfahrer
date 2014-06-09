class Api::V2::SearchesController < ApiController
  respond_to :json, :xml

  # POST /api/v2/search
  # create new search query
  def create
    departure_place = params[:departure_place]
    departure_place_threshold = params[:departure_place_threshold]
    destination = params[:destination]
    destination_threshold = params[:destination_threshold]
    departure_time = params[:departure_time]
    user = User.find_by(api_key: request.headers[:apiKey])
    ride_type = params[:ride_type]

    if user.nil?
      return render json: {:message => "user not found"}, status: :not_found
    else
      # add this search to table ride_searches which is displayed as a timeline
      user.ride_searches.create!(departure_place: departure_place, destination: destination,
                                 departure_time: departure_time, ride_type: ride_type)
    end

    begin
      @rides = []
      Ride.where("departure_time > ?", Time.now).each do |ride|
        @rides.append(ride)
      end
      @rides = @rides[0,5]

      render json: {:rides => @rides, each_serializer: RideSerializer}, status: :ok
    rescue
      render json: {:rides => nil}, status: :bad_request
    end

  end


  # TODO: change this. This is old code that was getting the duration of detour. We should change
  # it for distance of detour. Max distance is added as parameter to search
  # (departure_place_threshold, destination_threshold)

  # get duration of the ride
  def extra_duration(start_point, end_point, start_carpool, end_carpool)
    result = prepare_url(start_point, end_point, start_carpool, end_carpool)
    if !result.nil? && result["routes"].size > 0 && result["routes"].first["legs"].size > 0
      return (result["routes"].first["legs"].first["duration"]["value"])/60
    else
      return 0
    end
  end

  # call google api to get the duration
  def prepare_url(start_point, end_point, start_carpool, end_carpool)
    url = URI.parse(URI.encode("https://maps.googleapis.com/maps/api/directions/json?origin=\"#{start_point}\"&destination=\"#{end_point}\"&waypoints=\"#{start_carpool}\"|\"#{end_carpool}\"&region=de&sensor=false&API=AIzaSyBy5McoVoJP4Wcaa4aagbyUKDkBmKqiGxw"))
    res = HTTParty.get(url)
    return JSON.parse(res.body)
  end

end
