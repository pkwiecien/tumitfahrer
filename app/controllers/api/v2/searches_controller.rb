class Api::V2::SearchesController < ApiController
  respond_to :json, :xml

  # POST /api/v2/search?start_carpool=X&end_carpool=Y&ride_date=Z
  # create new search query
  def create
    start_carpool = params[:start_carpool]
    end_carpool = params[:end_carpool]
    ride_date = params[:ride_date]
    user = User.find_by(api_key: request.headers[:apiKey])
    ride_type = params[:ride_type]

    if user.nil?
      return render json: {:message => "user not found"}, status: :not_found
    else
      user.ride_searches.create!(departure_place: start_carpool, destination: end_carpool,
                                 departure_time: ride_date, ride_type: ride_type)
    end

    begin
      results = []
      Ride.all.each do |ride|

        duration = extra_duration(ride[:departure_place], ride[:destination], start_carpool, end_carpool)
        #if duration < ride[:duration]/10 && (ride_date-ride[:departure_time])/3600<24
        ride_attributes = ride.attributes
        ride_attributes[:detour] = duration
        ride_attributes[:driver_id] = ride.driver.id
        results.append(ride_attributes)
        #end
      end
      render json: {:rides => results}, status: :ok
    rescue
      render json: {:rides => nil}, status: :bad_request
    end

  end

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
