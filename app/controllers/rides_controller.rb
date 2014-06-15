class RidesController < ApplicationController
  before_action :signed_in_user, only: [:new, :destroy]

  def index
    @rides = Ride.all
    @users = User.all

  end
  def new
    @ride = Ride.new
  end

  def create
    @ride = current_user.rides.build(ride_params)
    if @ride.save
     # pusher = Grocer.pusher(certificate: "ck.pem", passphrase: 'simina')
      @rideInfo = "Ride from " + @ride.departure_place + " to " + @ride.destination + " on " + @ride.departure_time.to_datetime().strftime('%d %b %Y %H:%M:%S') + " o'clock"
     
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

  def show
    @ride = Ride.find(params[:id])
  end

  def destroy
    @ride.destroy
    redirect_to root_url

  end

 def ride_details
  @ride = Ride.find(params[:id])
 end

  private
  def ride_params
    params.require(:ride).permit(:departure_place, :destination, :departure_time, :free_seats, :meeting_point)
  end

end

