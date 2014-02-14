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

      pusher = Grocer.pusher(certificate: "ck.pem")
      rideInfo = "Ride from " + @ride.departure_place + " to " + @ride.destination + " on " + @ride.departure_time.to_datetime().strftime('%d %b %Y %H:%M:%S') + " o'clock"
      debugger.log rideInfo
      note = Grocer::Notification.new(device_token:"f4f382b537d663af6256649e412fc19110cbbdc3d80c04373c090a623810127e", alert: rideInfo,  sound: 'default', badge: 0)
      pusher.push(note)

      gcm = GCM.new("AIzaSyAOIFGwYitZ12XJu1-DOXuZAa2UaJk97F8")
      registration_ids= ["APA91bGBYGoCJ5T6HSjW5zZ_tuuc5ZERL5QKYBDl8698O-fLrex9u6L0GtOwupkUvUdLnGSJO_SEtbDYgTqVdLhgdSnTLBo0kQ8h2SvxlCNsVSD8_guyLO4-KNGntJzoA4BXbWRnsCEdXIpwC3tp1_fgUfvdoY69Wg"] # an array of one or more client registration IDs
      options = {data: {ride: @ride}, collapse_key: "updated_score"}
      response = gcm.send_notification(registration_ids, options)
      logger.debug response
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


  private

  def ride_params
    params.require(:ride).permit(:departure_place, :destination, :departure_time, :free_seats, :meeting_point)
  end

end

