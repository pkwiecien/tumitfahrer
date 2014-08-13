require 'geocoder'
require 'date'
require 'net/http'

URL = 'http://www.panoramio.com/map/get_panoramas.php'
DEFAULT_OPTIONS = {
    :set => :public, # Cant be :public, :full, or a USER ID number
    :size => :medium, # Cant be :original, :medium (default value), :small, :thumbnail, :square, :mini_square
    :from => 0,
    :to => 1,
    :mapfilter => true
}


class RidesController < ApplicationController
  before_action :signed_in_user, only: [:new, :destroy]
  respond_to :json

  def index
    @rides = Ride.all
    @users = User.all
  end

  def new
    @ride = Ride.new
  end

  def create
    departure_coordinates = Geocoder.coordinates(params[:ride][:departure_place])
    destination_coordinates = Geocoder.coordinates(params[:ride][:destination])
    params[:ride].merge!(:is_driving => params[:is_driving],
                         :departure_latitude => departure_coordinates[0],
                         :departure_longitude => departure_coordinates[1],
                         :destination_latitude => destination_coordinates[0],
                         :destination_longitude => destination_coordinates[1])

    @ride = Ride.create_ride_by_owner ride_params, current_user
    if @ride.save
      flash[:success] = "Ride was added!"
      redirect_to current_user
    else
      render 'new'
    end
  end

  def edit

  end

  def update

  end

  def search

  end


  def timeline

    @rides = Ride.where("user_id >?",3)
    @rides.each do |ride1|
      @yours_rides = Ride.where("Relationship.ride_id > ?",49)
    end

    @all = Ride.where("departure_time > ?", Time.now).order("departure_time asc").paginate(:page => params[:page], :per_page => 10)

      @t=Time.now.strftime("%Y-%m-%d")
      @today_rides = Ride.where("departure_time  like  '%#{@t}%'" ).limit(2).order("departure_time asc")

      @t=Time.now.tomorrow.strftime("%Y-%m-%d")
      @tomorrow_rides = Ride.where("departure_time  like  '%#{@t}%'" ).limit(2).order("departure_time asc")

      @t2=5.hours.from_now.strftime("%Y-%m-%d %H:%M:%S")
      @t1=Time.now.strftime("%Y-%m-%d %H:%M:%S")
      @lastminute_rides = Ride.where("departure_time  >  STR_TO_DATE('#{@t1}','%Y-%m-%d %H:%i:%s') and
                          departure_time < STR_TO_DATE('#{@t2}','%Y-%m-%d %H:%i:%s')" ).order("departure_time asc").paginate(:page => params[:page], :per_page => 10)


#select * from rides where (departure_time > STR_TO_DATE('2014-07-11 00:00:00','%Y-%m-%d %H:%i:%s') and
# departure_time < STR_TO_DATE('2014-07-11 22:30:00','%Y-%m-%d %H:%i:%s'));


    @time_diff_components = Array.new

    @all.each do |ride|
      @start_time = ride.departure_time
      @endtime = Time.now

      @time_diff_components.push(TimeDifference.between(@start_time, @endtime).in_minutes)
    end
  end

  def campus

    @campus_rides = Ride.where("departure_time > ? AND ride_type > ?", Time.now,0).order("departure_time asc").paginate(:page => params[:page], :per_page => 10)
    @pic_url = Array.new
    @campus_rides.each do |ride|
    @pic_url.push(get_picture ride.destination_latitude, ride.destination_longitude)
    end

  end


  def get_picture_from_panoramio
    lat = params[:lat]
    lng = params[:lng]
    url = get_picture lat, lng
    return render json: {status: :ok, url: url}
  end

  private

  def get_picture lat, lng
    lat = lat
    lng = lng
    options = {}
    points = Geocoder::Calculations.bounding_box([lat, lng], 10, { :unit => :mi })
    options.merge!({
                       :miny => points[0],
                       :minx => points[1],
                       :maxy => points[2],
                       :maxx => points[3]
                   })
    panoramio_options = DEFAULT_OPTIONS
    panoramio_options.merge!(options)
    response = RestClient.get URL, :params => panoramio_options
    if response.code == 200
      parse_data = JSON.parse(response.to_str)
      url = parse_data['photos'][0]['photo_file_url']
    else
      raise "Panoramio API error: #{response.code}. Response #{response.to_str}"
      url = ""
    end
    url
  end

  def show
    @ride = Ride.find(params[:id])
    render 'ride_details'
  end

  def destroy
    @ride.destroy
    redirect_to root_url

  end


  private

  def ride_params
    params.require(:ride).permit(:departure_place, :destination, :departure_time, :free_seats,
                                 :meeting_point, :ride_type, :is_driving, :car, :departure_latitude,
                                 :departure_longitude, :destination_latitude, :destination_longitude)
  end

end

