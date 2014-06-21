require 'geocoder'
class RidesController < ApplicationController
  before_action :signed_in_user, only: [:new, :destroy]

  @num_page_results = 10

  def index
    if params.has_key?(:from_date)
      get_rides_from_date DateTime.parse(params[:from_date]), params[:ride_type].to_i
    else
      page = 0

      if params.has_key?(:page)
        page = params[:page].to_i
      end

      campus_rides = Ride.where("ride_type = ? AND departure_time > ?", 0, Time.now)
      activity_rides = Ride.where("ride_type = ? AND departure_time > ?", 1, Time.now)
          #limit(@@num_page_results)

      @rides = campus_rides + activity_rides
      #unless @rides.nil?
        #respond_with @rides, status: :ok
      #else
        #respond_with :rides => [], status: :no_content
      #end
    end
  end

  def get_rides_from_date from_date, ride_type
    @rides = Ride.where("ride_type = ? AND updated_at > ?", ride_type, from_date-2.hours)
  end


  # GET api/v2/users/:user_id/rides
  # optional @param is_paid=true/false - get rides of the user that are paid or not
  def get_user_rides
    user = User.find_by(id: params[:user_id])
    #return respond_with :rides => [], :status => :not_found if user.nil?

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
    #respond_with @rides, status: :ok
  end

  #GET /api/v2/rides?past
  def get_past_rides user

    @rides = user.rides.where("departure_time < ?", Time.now)
    respond_with @rides, status: :ok

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

     # pusher = Grocer.pusher(certificate: "ck.pem", passphrase: 'simina')
      @rideInfo = "Ride from " + @ride.departure_place + " to " + @ride.destination + " on " + @ride.departure_time.to_datetime().strftime('%d %b %Y %H:%M:%S') + " o'clock"
     


      # pusher = Grocer.pusher(certificate: "ck.pem", passphrase: 'simina')
      #rideInfo = "Ride from " + @ride.departure_place + " to " + @ride.destination + " on " + @ride.departure_time.to_datetime().strftime('%d %b %Y %H:%M:%S') + " o'clock"
      # logger.debug rideInfo
      # note = Grocer::Notification.new(device_token:"f4f382b537d663af6256649e412fc19110cbbdc3d80c04373c090a623810127e", alert: rideInfo,  sound: 'default', badge: 0)
      # pusher.push(note)

<<<<<<< HEAD
      notification = Houston::Notification.new(device: "f4f382b537d663af6256649e412fc19110cbbdc3d80c04373c090a623810127e")
      notification.alert = rideInfo
      notification.badge = 57
      notification.sound = 'default'
      #APN.push(notification)

      gcm = GCM.new("AIzaSyAOIFGwYitZ12XJu1-DOXuZAa2UaJk97F8")
      registration_ids= ["APA91bGBYGoCJ5T6HSjW5zZ_tuuc5ZERL5QKYBDl8698O-fLrex9u6L0GtOwupkUvUdLnGSJO_SEtbDYgTqVdLhgdSnTLBo0kQ8h2SvxlCNsVSD8_guyLO4-KNGntJzoA4BXbWRnsCEdXIpwC3tp1_fgUfvdoY69Wg"] # an array of one or more client registration IDs
      options = {data: {ride: @ride}, collapse_key: "updated_score"}
      response = gcm.send_notification(registration_ids, options)
      logger.debug response

=======
      #notification = Houston::Notification.new(device: "f4f382b537d663af6256649e412fc19110cbbdc3d80c04373c090a623810127e")
      #notification.alert = rideInfo
      #notification.badge = 57
      #notification.sound = 'default'
      ##APN.push(notification)
      #
      #gcm = GCM.new("AIzaSyAOIFGwYitZ12XJu1-DOXuZAa2UaJk97F8")
      #registration_ids= ["APA91bGBYGoCJ5T6HSjW5zZ_tuuc5ZERL5QKYBDl8698O-fLrex9u6L0GtOwupkUvUdLnGSJO_SEtbDYgTqVdLhgdSnTLBo0kQ8h2SvxlCNsVSD8_guyLO4-KNGntJzoA4BXbWRnsCEdXIpwC3tp1_fgUfvdoY69Wg"] # an array of one or more client registration IDs
      #options = {data: {ride: @ride}, collapse_key: "updated_score"}
      #response = gcm.send_notification(registration_ids, options)
      #logger.debug response
>>>>>>> b2b59b3f985142e3b9fb11ed48780811a44bffbc
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
    params.require(:ride).permit(:departure_place, :destination, :departure_time, :free_seats,
                                 :meeting_point, :ride_type, :is_driving, :car, :departure_latitude,
                                 :departure_longitude, :destination_latitude, :destination_longitude)
  end

end

