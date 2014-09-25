require 'geocoder'
require 'net/http'

class RidesController < ApplicationController
  before_action :signed_in_user, only: [:new, :destroy, :update, :create]

  URL = 'http://www.panoramio.com/map/get_panoramas.php'
  DEFAULT_OPTIONS = {
      :set => :public, # Cant be :public, :full, or a USER ID number
      :size => :medium, # Cant be :original, :medium (default value), :small, :thumbnail, :square, :mini_square
      :from => 0,
      :to => 1,
      :mapfilter => true
  }

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
    if (params[:repeat][:start_date].nil? && params[:repeat][:end_date].nil?) || (params[:repeat][:start_date].empty? && params[:repeat][:start_date].empty?)
      @ride = Ride.create_ride_by_owner ride_params, current_user, params[:is_driving].to_i
    else
      start_date = Date.parse(params[:repeat][:start_date])
      end_date = Date.parse(params[:repeat][:end_date])
      ride_dates = []
      start_date.upto(end_date){ |date|
        puts date.inspect
        if (!params[:repeat][Date::ABBR_DAYNAMES[date.wday]].nil?)
          date_f = date.to_s + " " + params[:ride][:departure_time].split(" ")[1]
          ride_dates.append date_f
        end
      }

      @rides = Ride.create_regular_rides ride_dates, ride_params, current_user

    end

    if !@ride.nil? || !@rides.empty?
      flash[:success] = "Ride was added!"
      if !@ride.nil?
        final_ride = @ride
      else
        final_ride = @ride.first
      end

      redirect_to final_ride
    else
      render :new
    end
  end

  def edit

  end

  def update

  end

  def show
    @ride = Ride.find_by_id(params[:id])
    if @ride.nil?
      flash[:error] = "Ride not found."
      redirect_to root_url
    else
      @pic_url = get_picture @ride.destination_latitude, @ride.destination_longitude
    end

  end

  def destroy
    if params.has_key?(:regular_ride_id)
      rides = Ride.where(regular_ride_id: params[:regular_ride_id])
      rides.destroy_all
    else
      ride = Ride.find_by(id: params[:id])
      if ride.nil?
        flash[:error] = "Ride not found."
        redirect_to root_url
      end
      ride.destroy
    end

    redirect_to root_url

  end

  def remove_passenger
    ride = Ride.find_by(:id => params[:ride_id])
    ride.remove_passenger ride.ride_owner.id, params[:removed_passenger]

    redirect_to request.referer
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

  def ride_params
    params.require(:ride).permit(:departure_place, :destination, :departure_time, :free_seats,
                                 :meeting_point, :ride_type, :is_driving, :car, :departure_latitude,
                                 :departure_longitude, :destination_latitude, :destination_longitude)
  end

end

