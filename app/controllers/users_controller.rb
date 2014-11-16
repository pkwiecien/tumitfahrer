require 'digest/sha2'
require 'message_sender'

class UsersController < ApplicationController
  before_action :signed_in_user, only: [:edit, :update, :show, :my_rides]
  before_action :right_user, only: [:edit, :update, :my_rides]

  def check_email
    @user = User.find_by_email(params[:user][:email])

    respond_to do |format|
      format.json { render :json => !@user }
    end
  end




  URL = 'http://www.panoramio.com/map/get_panoramas.php'
  DEFAULT_OPTIONS = {
      :set => :public, # Cant be :public, :full, or a USER ID number
      :size => :medium, # Cant be :original, :medium (default value), :small, :thumbnail, :square, :mini_square
      :from => 0,
      :to => 1,
      :mapfilter => true
  }

  def check_email
    @user = User.find_by_email(params[:user][:email])

    respond_to do |format|
      format.json { render :json => !@user }
    end
  end

  def new
    if signed_in?
      redirect_to current_user
    else
      @user = User.new
    end
  end

  def create


    logger.debug "Env variable is: "
    logger.debug "here: #{ENV['S3_BUCKET_NAME']}"

    @user = User.new(user_params)


    new_password = User.generate_new_password
    hashed_password = User.generate_hashed_password(new_password)
    @user = User.new(user_params.merge(password: hashed_password, password_confirmation: hashed_password))


    if @user.save
      sign_in @user
      flash[:success] = "Welcome to TUMitfahrer!"
      UserMailer.welcome_email(@user,new_password).deliver
      redirect_to @user
    else
      render 'new'
    end

  end

 def my_rides
   @user = User.find_by(id: params[:id])

   if params.has_key?(:selected_div)
     @selected_div = params[:selected_div]
   else
     @selected_div = "created"
   end
   if @user.get_present_rides_as_driver !=[]
     @myridescreated_offers = @user.get_present_rides_as_driver.paginate(:page => params[:page], :per_page => 3)
   end
   if @user.get_present_requests_for_driver != []
     @myridescreatedrequest = @user.get_present_requests_for_driver.paginate(:page => params[:page], :per_page => 3)
   end
   if @user.rides_as_passenger != []
     @myridesjoined_accepted = @user.rides_as_passenger.paginate(:page => params[:page], :per_page => 3)
   end
   if @user.requested_rides != []
     @myridesjoined_pending = @user.requested_rides.paginate(:page => params[:page], :per_page => 3)
   end
    if @user.get_past_rides_as_driver != []
      @myridespast_offers = @user.get_past_rides_as_driver.paginate(:page => params[:page], :per_page => 3)
    end
   if @user.get_past_requests_for_driver != []
     @myridespast_requests = @user.get_past_requests_for_driver.paginate(:page => params[:page], :per_page => 3)
   end

   @pic_url = Array.new
   if @user.get_present_rides_as_driver != []
    @myridescreated_offers.each do |ride|
     @pic_url.push(get_picture ride.destination_latitude, ride.destination_longitude)
    end
   end
   if @user.get_present_requests_for_driver != []
   @myridescreatedrequest.each do |ride|
     @pic_url.push(get_picture ride.destination_latitude, ride.destination_longitude)
   end
   end
   if @user.rides_as_passenger != []
   @myridesjoined_accepted.each do |ride|
     @pic_url.push(get_picture ride.destination_latitude, ride.destination_longitude)
   end
   end
   if @user.requested_rides != []
   @myridesjoined_pending.each do |ride|
     @pic_url.push(get_picture ride.destination_latitude, ride.destination_longitude)
   end
   end
   if @user.get_past_rides_as_driver != []
   @myridespast_offers.each do |ride|
     @pic_url.push(get_picture ride.destination_latitude, ride.destination_longitude)
   end
   end
   if @user.get_past_requests_for_driver != []
   @myridespast_requests.each do |ride|
     @pic_url.push(get_picture ride.destination_latitude, ride.destination_longitude)
   end
   end


 end
  def get_picture_from_panoramio
    lat = params[:lat]
    lng = params[:lng]
    url = get_picture lat, lng
    return render json: {status: :ok, url: url}
  end

  def show
    #TODO: REMOVE THE FOLLOWING CODE JUST FOR TESTING BY BEHROZ
    #@result = Notification.get_notification_list
    #MessageSender.send_next_batch()

    #TODO: END
    @user = User.find_by(id: params[:id])
    #@rides = @user.rides.paginate(page: params[:page])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update_photo
    @user = User.find(params[:id])
    @user.avatar = params[:user][:avatar]
    if @user.save!
      redirect_to @user
    else
      flash[:error] = "Something went wrong. Please try again later."
      redirect_to @user
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params_edit)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :department,
                                 :password, :password_confirmation)
  end

  def user_params_edit
    params.require(:user).permit(:first_name, :last_name, :email, :department,
                                 :phone_number)
  end

  def user_params_avatar
    params.require(:user).permit(:avatar)
  end

  def right_user
    @user = User.find(params[:id])
    redirect_to root_url unless current_user?(@user)
  end

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

end

