class SearchesController < ApplicationController

  def create


    #if(params[:departure_place].present? && params[:destination].present? && params[:departure_time].present?)

     # @rides = Ride.where(:departure_place=>params[:departure_place],:destination => params[:destination],:departure_time =>params[:departure_time])


end
    
def index
@nearbyrides = Array.new
@ride = Ride.all
puts @ride.count
  @ride.each   do |ride|
    @departure_place1 = params[:departure_place]
    @departure_place2 = ride[:departure_place]
@distance = Geocoder::Calculations.distance_between(@departure_place1,@departure_place2)
      puts "departure: " + @departure_place2
      puts "distance is: " + @distance.to_s.to_f.to_s

     if @distance.to_f <= params[:departure_place_threshold].to_s.to_f
       puts "threshold is: " + params[:departure_place_threshold].to_s.to_f.to_s
        @nearbyrides.push(ride)

   end
end
@nearbyrides



  end
def search
 
  end
end

