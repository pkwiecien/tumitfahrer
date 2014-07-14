require 'geocoder'
require 'date'
class RidesController < ApplicationController
  before_action :signed_in_user, only: [:new, :destroy]
  respond_to :json

  def index
    @rides = Ride.all
    @users = User.all

    @campusrides = Ride.where(:ride_type => '0')
    @activityrides = Ride.where(:ride_type => '1')


    respond_to do |format|
      format.html
      format.json { render json: @campusrides }


    end
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
  def get_user_rides
    user = User.find_by(id: params[:user_id])


    if params.has_key?(:past)
      return get_past_rides user
    elsif params.has_key?(:driver)
      @rides = user.rides_as_driver
    elsif params.has_key?(:passenger)
      @rides = user.rides_as_passenger
    else
      @rides = user.all_rides
    end

    if params.has_key?(:is_paid)
      @rides = @rides.where(is_paid: params[:is_paid])
    end
    respond_with @rides, status: :ok
  end


  def timeline
    @users = User.find_by(id: params[:user_id])
  @rides = Ride.where("user_id = ?",4)
    #@rides = Ride.all
    @rides1 = Ride.where
    #@rides = Ride.paginate :page => params[:page], :order => 'created_at DESC'
    @all = Ride.where("departure_time > ?", Time.now).order("departure_time asc")



    #@all.each do |ride1|
      @t=Time.now.strftime("%Y-%m-%d")
      @today_rides = Ride.where("departure_time  like  '%#{@t}%'" ).limit(2)
    #end

    #@all.each do |ride1|
      @t=Time.now.tomorrow.strftime("%Y-%m-%d")
      @tomorrow_rides = Ride.where("departure_time  like  '%#{@t}%'" ).limit(2)
    #end

    #@all.each do |ride1|
      @t2=5.hours.from_now.strftime("%Y-%m-%d %H:%M:%S")
      @t1=Time.now.strftime("%Y-%m-%d %H:%M:%S")
      @lastminute_rides = Ride.where("departure_time  >  STR_TO_DATE('#{@t1}','%Y-%m-%d %H:%i:%s') and
                          departure_time < STR_TO_DATE('#{@t2}','%Y-%m-%d %H:%i:%s')" )
    #end

#select * from rides where (departure_time > STR_TO_DATE('2014-07-11 00:00:00','%Y-%m-%d %H:%i:%s') and
# departure_time < STR_TO_DATE('2014-07-11 22:30:00','%Y-%m-%d %H:%i:%s'));


    @time_diff_components = Array.new

    @all.each do |ride|
      @start_time = ride.departure_time
      @endtime = Time.now

      @time_diff_components.push(TimeDifference.between(@start_time, @endtime).in_minutes)
    end


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

