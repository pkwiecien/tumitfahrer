class SearchesController < ApplicationController

  def search_rides
    @departure_place = params[:departure_place]
    @departure_threshold = params[:departure_place_threshold].to_i
    @destination = params[:destination]
    @destination_threshold = params[:destination_threshold].to_i
    if params.has_key?(:departure_time)
      @departure_time = Time.zone.parse(params[:departure_time])
    end
    user = current_user
    @ride_type = params[:ride_type].to_i

    if @departure_place.nil?
      @departure_place = ""
    end
    if @destination.nil?
      @destination = ""
    end
    #if user.nil?
    #  return render json: {:message => "user not found"}, status: :not_found
    #else
    #  # add this search to table ride_searches which is displayed as a timeline
    #  user.ride_searches.create!(departure_place: departure_place, destination: destination,
    #                             departure_time: departure_time, ride_type: ride_type)
    #end

    @rides = Ride.rides_nearby @departure_place, @departure_threshold, @destination,
                              @destination_threshold, @departure_time, @ride_type

  end

end
