class SearchesController < ApplicationController

  def create


    #if(params[:departure_place].present? && params[:destination].present? && params[:departure_time].present?)

     # @rides = Ride.where(:departure_place=>params[:departure_place],:destination => params[:destination],:departure_time =>params[:departure_time])


end
    
def index

results = []
@ride = Ride.all
  @ride.each   do |ride|
    @departure_place1 = params[:departure_place]
    @departure_place2 = ride[:departure_place]
    @result = Array.new
    @result = Geocoder::Calculations.distance_between(@departure_place1,@departure_place2)
     if @result < params[:departure_place_threshold].to_s.to_f
	@rides= Ride.all
   end
end
@rides = Ride.all


  end
def search
 
  end
end

