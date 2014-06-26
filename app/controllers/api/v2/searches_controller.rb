class Api::V2::SearchesController < ApiController
  respond_to :json, :xml

  # POST /api/v2/search
  # create new search query
  def create
    departure_place = params[:departure_place]
    departure_threshold = params[:departure_place_threshold].to_i
    destination = params[:destination]
    destination_threshold = params[:destination_threshold].to_i
    if params.has_key?(:departure_time)
      departure_time = Time.zone.parse(params[:departure_time])
    end
    user = User.find_by(api_key: request.headers[:apiKey])
    ride_type = params[:ride_type].to_i

    if user.nil?
      return render json: {:message => "user not found"}, status: :not_found
    else
      # add this search to table ride_searches which is displayed as a timeline
      user.ride_searches.create!(departure_place: departure_place, destination: destination,
                                 departure_time: departure_time, ride_type: ride_type)
    end

    rides = Ride.rides_nearby departure_place, departure_threshold, destination,
                              destination_threshold, departure_time, ride_type


    if rides.count > 0
      render json: {:rides => rides, each_serializer: RideSerializer}, status: :ok
    else
      render json: {:rides => []}, status: :no_content
    end

  end


end
